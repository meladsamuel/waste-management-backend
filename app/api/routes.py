from flask import Blueprint, jsonify, request, abort, send_file
from app.models import Basket, User, Waste, commit, Area, SoftwareVersion, Role, Permission, BasketSection, AuthError
from app.validate import validate
from datetime import datetime
from io import BytesIO
from flask_jwt_extended import JWTManager, create_access_token, create_refresh_token, jwt_required, get_jwt_identity, \
    get_jwt
from itsdangerous import URLSafeSerializer
import qrcode

api = Blueprint('api', __name__, url_prefix='/api')

jwt = JWTManager()
save_serializer = URLSafeSerializer("current_app.config.get('SECRET_KEY')")


def setup_jwt(app):
    jwt.init_app(app)


@api.route('/')
def index():
    return jsonify({"api": "working"})


@api.route('baskets')
def get_baskets():
    args = request.args
    section_level = args.get('section_level', default=None, type=float)
    basket_level = args.get('basket_level', default=None, type=float)
    baskets = Basket.query.all()

    if section_level or basket_level:
        baskets_list = []
        for basket in baskets:
            current_basket = basket.check_level(section_level, basket_level)
            if current_basket:
                baskets_list.append(current_basket)

        return jsonify({"baskets": baskets_list})

    baskets_list = [basket.format() for basket in baskets]
    return jsonify({
        "baskets": baskets_list,
        "total_baskets": len(baskets_list)
    })


@api.route('baskets/<int:basket_id>')
def get_basket(basket_id):
    basket = Basket.query.get(basket_id)
    return jsonify({
        "basket": basket.format()
    })


@api.route('baskets/<int:basket_id>/wastes')
def get_wastes_of_basket(basket_id):
    sections = BasketSection.query.filter_by(basket_id=basket_id).all()
    wastes = []
    for section in sections:
        wastes.append({
            "category": section.category,
            "data": [waste.format_level() for waste in section.wastes]
        })
    return jsonify({
        "basket_id": basket_id,
        "wastes": wastes
    })


@api.route('baskets', methods=['POST'])
def add_new_basket():
    data = request.json
    longitude = data['longitude']
    latitude = data['latitude']
    micro_controller = data['micro_controller']
    sections = data['sections']
    basket = Basket(longitude=longitude, latitude=latitude, micro_controller=micro_controller)
    for section in sections:
        section = BasketSection(height=section['section_height'], width=section['section_width'],
                                length=section['section_length'], category=section['section'])
        basket.sections.append(section)
    basket.save()
    return jsonify({
        "success": True,
        "basket": basket.format()
    })


@api.route('baskets/<int:basket_id>', methods=['DELETE'])
def delete_baskets(basket_id):
    basket = Basket.query.get(basket_id)
    basket = basket.delete() if basket else basket
    return jsonify({
        'success': bool(basket)
    })


@api.route('baskets', methods=['PATCH'])
def update_all_baskets():
    data = request.json
    software_version = data['software_version']
    baskets = Basket.query.update({Basket.software_version: software_version})
    commit()
    return jsonify({
        "baskets_update": baskets
    })


@api.route('baskets/<int:basket_id>', methods=['PATCH'])
def update_the_basket(basket_id):
    data = request.json
    basket_level = data['level']
    if basket_level is None:
        abort(400)
    try:
        basket = Basket.query.get(basket_id)
        basket.wastes_height = basket_level
        basket.save()
    except:
        abort(422)

    return jsonify({
        "success": True,
    })


@api.route('areas')
def get_areas():
    areas = Area.query.all()
    areas_list = [area.format() for area in areas]

    return jsonify({
        "total_areas": len(areas_list),
        "areas": areas_list
    })


@api.route('areas/<int:area_code>')
def get_area(area_code):
    area = Area.query.get(area_code)
    return jsonify({
        "area": area.format()
    })


@api.route('areas/<int:area_code>/baskets')
def get_basket_belong_to_area(area_code):
    baskets = Area.query.get(area_code).baskets
    baskets_list = [basket.format() for basket in baskets]
    return jsonify({
        "total_baskets": len(baskets_list),
        "baskets": baskets_list
    })


@api.route('areas/<int:area_code>/users')
def get_user_belong_to_area(area_code):
    users = Area.query.get(area_code).users
    users_list = [user.format() for user in users]
    return jsonify({
        "total_users": len(users_list),
        "users": users_list
    })


@api.route('areas', methods=['POST'])
def insert_new_area():
    data = request.json
    roles = ['area_code', 'area_name', 'area_size', 'longitude', 'latitude', 'city']
    if not validate(roles, data):
        abort(422)
    code = data['area_code']
    name = data['area_name']
    size = data['area_size']
    longitude = data['longitude']
    latitude = data['latitude']
    city = data['city']
    area = Area(code=code, name=name, size=size, longitude=longitude, latitude=latitude, city=city)
    area.save(True)
    return jsonify({
        "success": True,
        "area": area.format()
    })


@api.route('roles')
def get_roles():
    roles = Role.query.all()
    list_role = [role.format() for role in roles]
    return jsonify({"roles": list_role})


@api.route('roles/<string:role_name>')
def get_one_role(role_name):
    role = Role.query.get(role_name)
    if role is None:
        abort(404, "role not found")
    return jsonify({"role": role.format()})


@api.route('roles', methods=["POST"])
def create_new_role():
    req = request.get_json(force=True)
    name = req.get('name', None)
    description = req.get('description', None)
    try:
        new_role = Role(name=name, description=description).create()
        return jsonify({
            "success": True,
            "role": new_role.format()
        })
    except:
        abort(501, "can not create new role")


@api.route('permissions')
def get_permissions():
    permissions = Permission.query.all()
    list_permissions = [permission.format() for permission in permissions]
    return jsonify({"permissions": list_permissions})


@api.route('permissions/<string:permission_name>')
def get_one_permission(permission_name):
    permission = Permission.query.get(permission_name)
    if permission is None:
        abort(404, "permission not found")
    return jsonify({"permission": permission.format()})


@api.route('permissions', methods=["POST"])
def create_new_permission():
    req = request.get_json(force=True)
    name = req.get('name', None)
    description = req.get('description', None)
    if Permission.query.get(name):
        return jsonify({
            "success": False,
            "message": "The permission is already exist",
            "error": 501
        }), 501
    new_permission = Permission(name=name, description=description).create()
    return jsonify({
        "success": True,
        "permission": new_permission.format()
    })


@api.route('permissions/<string:permission>', methods=['DELETE'])
def delete_permission(permission):
    permission = Permission.query.get(permission)
    permission.delete()
    return jsonify({
        'success': True
    })


@api.route('users')
def get_all_users():
    args = request.args
    if 'search' in args:
        search = args['search'].split()
        if len(search) == 2:
            first_name = "%{}%".format(search[0])
            last_name = "%{}%".format(search[1])
            users = User.query.filter(User.first_name.like(first_name) & User.last_name.like(last_name)).all()
            return jsonify({"user": [user.format() for user in users]})
        else:
            value = "%{}%".format(search[0])
            users = User.query.filter(User.first_name.like(value) | User.email.like(value)).all()
            return jsonify({"user": [user.format() for user in users]})
    users = User.query.all()
    return jsonify({"user": [user.format() for user in users]})


@api.route('users/<int:user_id>')
def get_one_user(user_id):
    user = User.query.get(user_id)
    return jsonify({
        "user": user.format()
    })


@api.route('users', methods=['POST'])
def create_new_user():
    req = request.get_json(force=True)
    username = req.get('username', None)
    email = req.get('email', None)
    password = req.get('password', None)
    first_name = req.get('first_name', None)
    last_name = req.get('last_name', None)
    gender = req.get('gender', None)
    user = User(user_name=username, email=email, first_name=first_name, last_name=last_name,
                gender=gender).set_password(password).save().send_verification_email()
    return jsonify({
        "success": True,
        'user': user.format(),
        "access_token": create_access_token(user.id),
        "refresh_token": create_refresh_token(user.id)
    }), 201


@api.route('users/activate', methods=['PATCH'])
def activate_user():
    req = request.get_json(force=True)
    token = req.get('token', None)
    user = User.email_verify(token)
    if not user:
        raise AuthError("token is invalid", 400)
    user.is_active = True
    user.save()
    return jsonify({
        "success": True,
        "access_token": create_access_token(user.id)
    }), 200


@api.route('users/disable', methods=['PATCH'])
def disable_user():
    req = request.get_json(force=True)
    user = User.query.get(user_name=req.get('id', None))
    user.is_active = False
    try:
        user.save()
        return jsonify({'success': True})
    except:
        abort(422)


@api.route('users/auth', methods=['POST'])
def authenticate_user():
    req = request.get_json(force=True)
    username = req.get('username', None)
    password = req.get('password', None)
    if not username and not password:
        raise AuthError('username and password is required', 422)
    user = User.query.filter_by(user_name=username).one_or_none()
    if not user:
        raise AuthError("username or password not valid", 401)
    token = user.authenticate(username, password)
    return jsonify({
        "user": user.format(),
        "access_token": token["access_token"],
        "refresh_token": token["refresh_token"]
    }), 200


@api.route('users/auth/refresh', methods=["POST"])
@jwt_required(refresh=True)
def refresh_user_token():
    identity = get_jwt_identity()
    print(identity)
    access_token = create_access_token(identity=identity, fresh=False)
    return jsonify(access_token=access_token)


@api.route('users/<int:user_id>/roles', methods=['PATCH'])
def set_role_for_user(user_id):
    req = request.get_json(force=True)
    role_name = req.get('role_name', None)
    try:
        user = User.query.get(user_id)
        user.role = Role.query.get(role_name)
        user.save()
    except:
        abort(501, "can not set the role for the user")
    return jsonify({"success": True})


@api.route('roles/<string:role_name>/permissions')
def get_permissions_belong_to_role(role_name):
    role = Role.query.get(role_name)
    return jsonify({
        "role": {
            "name": role.name,
            "description": role.description,
            "permissions": [permission.format() for permission in role.permissions]
        }
    })


@api.route('roles/<string:role_name>/permissions', methods=['PATCH'])
def set_permissions_for_role(role_name):
    req = request.get_json(force=True)
    permissions = req.get('permissions', None)
    role = Role.query.get(role_name)
    role.permissions += Permission.query.filter(Permission.name.in_(permissions)).all()
    role.create()
    return jsonify({"success": True})


@api.route('roles/<string:role_name>/permissions', methods=['DELETE'])
def remove_permissions_for_role(role_name):
    req = request.get_json(force=True)
    permissions_list = req.get('permissions', None)
    role = Role.query.get(role_name)
    permissions = Permission.query.filter(Permission.name.in_(permissions_list)).all()
    for permission in permissions:
        role.permissions.remove(permission)
    role.update()
    return jsonify({"success": True, "permissions": permissions_list})


@api.route('wastes')
def get_waste():
    data = request.args
    basket_id = data.get('basket_id', 0, int)
    wastes = Waste.query.all() if not basket_id else Waste.query.filter_by(basket_id=basket_id).all()
    wastes_list = [waste.format() for waste in wastes]
    total_size = 0
    for waste in wastes_list:
        total_size += +waste['size']

    return jsonify({
        "total_wastes_size": total_size,
        "wastes": wastes_list,
    })


@api.route('wastes', methods=['POST'])
def insert_new_waste():
    data = request.json
    basket = Basket.query.get(data['basket_id'])
    is_full = basket.set_wastes_height(data['waste_height'])
    if is_full:
        abort(422)
    waste_size = basket.get_waste_volume(data['waste_height'])
    waste = Waste(size=waste_size, type='bio', DOC=datetime.utcnow(), basket=basket).save()
    return jsonify({
        "basket_level": basket.get_basket_level(),
        "waste": waste.format()
    })


@api.route('wastes', methods=['DELETE'])
def delete_waste():
    # waste = Waste.query.filter_by(type='bio').delete()
    # db.session.commit()
    waste = Waste.query.all()
    print(waste)

    return ''


@api.route('test', methods=['POST', "GET"])
def test():
    data = request.json
    return jsonify({
        "value": data['value']
    })


# @api.route("/baskets_types")
# def get_basket_type():
#     types_of_baskets = BasketType.query.all()
#     type_list = [type_of_basket.format() for type_of_basket in types_of_baskets]
#     return jsonify({
#         "types": type_list
#     })


# @api.route("/baskets_types", methods=["POST"])
# def create_basket_type():
#     data = request.json
#     length = data["length"]
#     height = data["height"]
#     width = data["width"]
#     micro_controller = data["micro_controller"]
#     roles = ['length', 'height', 'width']
#     abort(400) if not validate(roles, data) else None
#     try:
#         basket_type = BasketType(length=length, height=height, width=width, micro_controller=micro_controller).save()
#         return jsonify({
#             "success": True,
#             'Type': basket_type.format()
#         })
#     except:
#         abort(422)


@api.route('/baskets/<int:basket_id>/versions')
def get_basket_software_version(basket_id):
    basket = Basket.query.get(basket_id)
    software_versions = SoftwareVersion.query.filter_by(basket_id=basket_id).order_by(SoftwareVersion.date.desc()).all()
    list_software_version = []
    status = 'update'
    for software_version in software_versions:
        if software_version.version == basket.software_version:
            status = 'rollback'
            list_software_version.append(software_version.format('current'))
            continue
        list_software_version.append(software_version.format(status))
    return jsonify({
        "software_versions": list_software_version,
        "current_version": basket.software_version
    })


@api.route("/software_versions/<int:basket_id>/<string:version>")
def get_file(basket_id, version):
    software = SoftwareVersion.query.filter_by(version=version, basket_id=basket_id).first()
    file_name = "{}.bin".format(software.version)
    return send_file(BytesIO(software.file), attachment_filename=file_name, as_attachment=True)


@api.route("/software_versions", methods=["POST"])
def post_file():
    file = request.files['file']
    update_type = request.form.get("update_type", None)
    basket_id = request.form.get("basket_id", None)
    basket = Basket.query.get(basket_id)
    last_version = SoftwareVersion.query.filter_by(basket_id=basket_id).order_by(SoftwareVersion.date.desc()).first()
    if last_version:
        major, minor, patch = last_version.version.split(".")
        if update_type == "patch":
            patch = int(patch) + 1
        elif update_type == "minor":
            minor = int(minor) + 1
            patch = 0
        elif update_type == "major":
            major = int(major) + 1
            patch = 0
            minor = 0
        else:
            abort(422)
        print(last_version.version.split())
        version = "{}.{}.{}".format(major, minor, patch)
    else:
        version = "0.1.0"
    print(version)
    print(last_version)
    software_version = SoftwareVersion(version=version, file=file.read(), basket=basket)
    software_version.save(True)
    return jsonify({
        "success": True,
        "version": software_version.version
    }), 201


@api.route('/baskets/<int:basket_id>/qr_code')
def get_basket_qr_code(basket_id):
    basket = Basket.query.get(basket_id)
    pil_img = qrcode.make(jsonify({"id": basket.id, "lng": basket.longitude, "lat": basket.latitude}))
    img_io = BytesIO()
    pil_img.save(img_io, 'PNG')
    img_io.seek(0)
    return send_file(img_io, mimetype='image/png')


@api.route('/qr_code', methods=['POST'])
def generate_qr_code():
    data = request.get_data()
    pil_img = qrcode.make(data)
    img_io = BytesIO()
    pil_img.save(img_io, 'PNG')
    img_io.seek(0)
    return send_file(img_io, mimetype='image/png')


@jwt.additional_claims_loader
def add_claims_to_access_token(identity):
    claims = {}
    user = User.query.get(identity)
    if user:
        claims['active'] = user.is_active
        if user.role_name:
            claims['permissions'] = [permission.name for permission in user.role.permissions]
    return claims


@api.errorhandler(AuthError)
def auth_error(error):
    return jsonify({
        "success": False,
        "message": error.error,
        "error": error.status_code
    }), error.status_code
