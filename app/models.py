from flask import current_app, render_template, abort
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import create_access_token, create_refresh_token
from flask_mail import Mail, Message
import bcrypt
from itsdangerous import URLSafeSerializer, SignatureExpired

db = SQLAlchemy()
mail = Mail()
save_serializer = URLSafeSerializer("current_app.config.get('SECRET_KEY')")


def setup_db(app):
    db.app = app
    db.init_app(app)
    mail.init_app(app)
    migrate = Migrate(app, db)


def commit():
    db.session.commit()


collect = db.Table('collect',
                   db.Column('plate_number', db.Integer, db.ForeignKey('vehicles.plate_number'), primary_key=True),
                   db.Column('basket_id', db.Integer, db.ForeignKey('baskets.id'), primary_key=True),
                   db.Column('DOC', db.DateTime, primary_key=True)
                   )

complaint = db.Table('complaint',
                     db.Column('user_id', db.Integer, db.ForeignKey('users.id'), primary_key=True),
                     db.Column('basket_id', db.Integer, db.ForeignKey('baskets.id'), primary_key=True),
                     db.Column('date_of_compliant', db.DateTime, primary_key=True),
                     db.Column('compliant_message', db.String),
                     )

rolePermission = db.Table('roles_permissions',
                          db.Column('role_name', db.String, db.ForeignKey('roles.name'), primary_key=True),
                          db.Column('permission_name', db.String, db.ForeignKey('permissions.name'), primary_key=True)
                          )


class Basket(db.Model):
    __tablename__ = 'baskets'
    id = db.Column(db.Integer, primary_key=True)
    longitude = db.Column(db.Float, nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    software_version = db.Column(db.String, nullable=False, default="0.0.0")
    wastes_height = db.Column(db.Integer, nullable=False, default=0)
    wastes = db.relationship('Waste', lazy=True, backref=db.backref('basket', lazy=True))
    software_versions = db.relationship('SoftwareVersion', lazy=True, backref=db.backref('basket', lazy=True))
    # type = db.Column(db.Integer, db.ForeignKey('basketsTypes.id'), nullable=False)
    area_code = db.Column(db.Integer, db.ForeignKey('areas.code'))
    micro_controller = db.Column(db.String, nullable=False)

    def save(self):
        if self.id is None:
            db.session.add(self)
        db.session.commit()
        return self

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def format(self):
        return {
            "id": self.id,
            "longitude": self.longitude,
            "latitude": self.latitude,
            "software_version": self.software_version,
            "micro_controller": self.micro_controller,
            "level": self.get_basket_section_level()
        }

    def get_basket_section_level(self):
        basket_height = 0
        sections_levels_in_basket = []
        wastes_level_in_section = []
        for section in self.sections:
            basket_height += section.height
            wastes_level_in_section.append(section.get_section_level())
        for section in self.sections:
            sections_levels_in_basket.append(section.height * 100 / basket_height)
        return {
            "sections_levels_in_the_basket": sections_levels_in_basket,
            "wastes_level_in_the_section": wastes_level_in_section
        }


class BasketSection(db.Model):
    height = db.Column(db.SmallInteger, nullable=False)
    width = db.Column(db.SmallInteger, nullable=False)
    length = db.Column(db.SmallInteger, nullable=False)
    fullness_level = db.Column(db.SmallInteger, default=0)
    category = db.Column(db.String, primary_key=True)
    basket_id = db.Column(db.Integer, db.ForeignKey('baskets.id'), primary_key=True)
    basket = db.relationship('Basket', backref=db.backref('sections'))

    def set_wastes(self, waste_height):
        if waste_height <= (self.height - self.fullness_level):
            self.fullness_level += waste_height
            abort(501, "basket is fullness can not add new waste in the system")
        return True

    def get_waste_volume(self, height):
        cubic_centimeter = 1000000  # 1 cubic meter equal 1000000 cubic centimeter
        waste_volume_in_centimeter = self.length * self.width * int(height)
        waste_volume_in_meter = waste_volume_in_centimeter / cubic_centimeter
        return waste_volume_in_meter

    def get_section_level(self):
        return self.fullness_level * 100 / self.height

    def create(self):
        db.session.add(self)
        db.session.commit()
        return self

    def update(self):
        db.session.commit()
        return self

    def format(self):
        return {
            "category": self.category,
            "height": self.height,
            "width": self.width,
            "length": self.length,
            "fullness_level": "{}%".format(self.get_section_level()),
            "basket": self.basket_id,
        }


class Area(db.Model):
    __tablename__ = "areas"
    code = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, unique=True, nullable=False)
    size = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.String, nullable=False)
    latitude = db.Column(db.String, nullable=False)
    city = db.Column(db.String, nullable=False)
    baskets = db.relationship('Basket', lazy=False, backref=db.backref('area'))
    users = db.relationship('User', backref=db.backref('area'))

    def save(self, has_key_by_default=False):
        if self.code is None or has_key_by_default:
            db.session.add(self)
        db.session.commit()

    def format(self):
        return {
            "area_code": self.code,
            "area_name": self.name,
            "area_size": self.size,
            "longitude": self.longitude,
            "latitude": self.latitude,
            "city": self.city
        }


class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String, unique=True)
    first_name = db.Column(db.String, nullable=False)
    last_name = db.Column(db.String, nullable=False)
    email = db.Column(db.String, nullable=False, unique=True)
    password = db.Column(db.String, nullable=False)
    gender = db.Column(db.String, nullable=False)
    DOB = db.Column(db.DateTime)
    phone = db.Column(db.String)
    area_code = db.Column(db.Integer, db.ForeignKey('areas.code'))
    is_active = db.Column(db.Boolean, default=False, server_default="false")
    role_name = db.Column(db.String(), db.ForeignKey('roles.name'))
    baskets = db.relationship('Basket', secondary=complaint, lazy=True, backref=db.backref('complainants'))

    @staticmethod
    def check_username_or_email_existing(username, email):
        user_exists = User.query.filter((User.email == email) | (User.user_name == username)).one_or_none()
        if user_exists and user_exists.user_name == username and user_exists.email == email:
            raise AuthError('username and email are exists', 409)
        elif user_exists and user_exists.user_name == username:
            raise AuthError('the username is exists in our system', 409)
        elif user_exists and user_exists.email == email:
            raise AuthError('your email is exists', 409)

    def authenticate(self, user_name, password):
        if not self.valid_password(password) or self.user_name != user_name:
            raise AuthError("username or password not valid", 401)
        return {
            "access_token": create_access_token(self.id),
            "refresh_token": create_refresh_token(self.id)
        }

    def send_verification_email(self):
        data = {
            "redirect_url": current_app.config.get('CONFIRMATION_REDIRECT_URL'),
            "token": save_serializer.dumps(self.user_name, salt='thisIsEmailSalt'),
            "user": self,
        }
        msg = Message("Please confirm your registration", recipients=[self.email])
        msg.html = render_template('mail/registration.html', **data)
        mail.send(msg)
        return self

    @staticmethod
    def email_verify(token):
        try:
            username = save_serializer.loads(token, salt="thisIsEmailSalt", max_age=3600)
            print(username)
            return User.query.filter(User.user_name == username).one_or_none()
        except SignatureExpired:
            raise AuthError("token expired", 400)

    def set_password(self, plaint_password):
        self.password = bcrypt.hashpw(plaint_password.encode('utf-8'), bcrypt.gensalt()).decode()
        return self

    def valid_password(self, plaint_password):
        return bcrypt.checkpw(plaint_password.encode('utf-8'), self.password.encode('utf-8'))

    def save(self):
        if self.id is None:
            User.check_username_or_email_existing(self.user_name, self.email)
            db.session.add(self)
        db.session.commit()
        return self

    def format(self):
        return {
            "id": self.id,
            "user_name": self.user_name,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "gender": self.gender,
            "Date_of_birth": self.DOB,
            "role": self.role_name
        }


class Role(db.Model):
    __tablename__ = "roles"
    name = db.Column(db.String(), primary_key=True)
    description = db.Column(db.String())
    user = db.relationship('User', lazy=True, backref=db.backref('role'))
    permissions = db.relationship('Permission', secondary=rolePermission, backref=db.backref('role'), lazy=False)

    def create(self):
        db.session.add(self)
        db.session.commit()
        return self

    def update(self):
        db.session.commit()
        return self

    def format(self):
        return {
            "name": self.name,
            "description": self.description,
        }


class Permission(db.Model):
    __tablename__ = "permissions"
    name = db.Column(db.String, primary_key=True)
    description = db.Column(db.String)

    def create(self):
        db.session.add(self)
        db.session.commit()
        return self

    def update(self):
        db.session.commit()
        return self

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def format(self):
        return {
            "name": self.name,
            "description": self.description,
        }


class Employee(db.Model):
    __tablename__ = 'employees'
    SSN = db.Column(db.BigInteger, primary_key=True)
    full_name = db.Column(db.String, nullable=False)
    user_name = db.Column(db.String, nullable=False, unique=False)
    password = db.Column(db.String, nullable=False)
    DOB = db.Column(db.DateTime, nullable=False)
    phone = db.Column(db.String)
    vehicle = db.relationship('Vehicle', uselist=False, lazy="select", backref=db.backref('driver'))
    supervise = db.relationship("Employee")
    supervise_SSN = db.Column(db.BigInteger, db.ForeignKey('employees.SSN'), nullable=True)

    def save(self, has_key_by_default=False):
        if self.SSN is None or has_key_by_default:
            db.session.add(self)
        db.session.commit()

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def format(self):
        return {
            "SSN": self.SSN,
            "full_name": self.full_name,
            "user_name": self.user_name,
            "date_of_birth": self.DOB,
            "phone": self.phone
        }


class Vehicle(db.Model):
    __tablename__ = "vehicles"
    plate_number = db.Column(db.Integer, primary_key=True)
    container_size = db.Column(db.Float)
    tank_level = db.Column(db.Float)
    tank_size = db.Column(db.Float)
    employee_SSN = db.Column(db.BigInteger, db.ForeignKey('employees.SSN'))
    baskets = db.relationship('Basket', secondary=collect, lazy=True, backref=db.backref('baskets'))

    def save(self, has_key_by_default=False):
        if self.plate_number is None or has_key_by_default:
            db.session.add(self)
        db.session.commit()

    def format(self):
        return {
            "plate_number": self.plate_number,
            "container_size": self.container_size,
            "tank_level": self.tank_level,
            "tank_size": self.tank_size,
            "driver": self.driver.format() if self.driver else {}
        }


class Waste(db.Model):
    __tablename__ = "wastes"
    id = db.Column(db.Integer, primary_key=True)
    size = db.Column(db.Float)
    type = db.Column(db.String)
    DOC = db.Column(db.DateTime, nullable=False)
    basket_id = db.Column(db.Integer, db.ForeignKey('baskets.id'), nullable=True)

    def save(self, has_key_by_default=False):
        if self.id is None or has_key_by_default:
            db.session.add(self)
            db.session.add(self.basket)
        db.session.commit()
        return self

    def format(self):
        return {
            "basket_id": self.basket_id,
            "size": self.size,
            "type": self.type,
            "date_of_creation": self.DOC
        }

    def delete(self):
        db.session.commit()


class SoftwareVersion(db.Model):
    __tablename__ = "software_versions"
    version = db.Column(db.String(), primary_key=True)
    file = db.Column(db.LargeBinary())
    date = db.Column(db.DateTime, server_default=db.func.now())
    basket_id = db.Column(db.Integer, db.ForeignKey('baskets.id'), nullable=True, primary_key=True)

    def save(self, has_key_by_default=False):
        if self.version is None or has_key_by_default:
            db.session.add(self)
        db.session.commit()
        return self

    def format(self, status):
        return {
            "version": self.version,
            "date": self.date,
            "status": status
        }

    def delete(self):
        db.session.commit()


class AuthError(Exception):
    def __init__(self, error, status_code):
        self.error = error
        self.status_code = status_code
