import os
from dotenv import load_dotenv

load_dotenv()

CONFIG_PATH = os.path.abspath(__file__)
ROOT_DIR = os.path.dirname(CONFIG_PATH)
UPLOAD_DIRECTORY = os.path.join(ROOT_DIR, 'uploads')
TEMPLATE_DIRECTORY = os.path.join(ROOT_DIR, 'app/templates')


class Config(object):
    DEBUG = False
    TESTING = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
    SESSION_COOKIE_SECURE = True
    SECRET_KEY = os.environ.get("SECRET_KEY")
    BCRYPT_HASH_PREFIX = os.environ.get('BCRYPT_HASH_PREFIX')
    JWT_ACCESS_LIFESPAN = {"hours": 24}
    JWT_REFRESH_LIFESPAN = {"days": 30}
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = MAIL_USERNAME
    MAIL_SERVER = os.environ.get('MAIL_SERVER')
    MAIL_PORT = int(os.environ.get('MAIL_PORT'))
    MAIL_USE_TLS = (os.environ.get('MAIL_USE_TLS') == 'true')
    MAIL_USE_SSL = (os.environ.get('MAIL_USE_SSL') == 'true')
    CONFIRMATION_REDIRECT_URL = os.environ.get('CONFIRMATION_REDIRECT_URL')


class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class DevelopmentConfig(Config):
    ENV = "development"
    DEVELOPMENT = True
    SQLALCHEMY_TRACK_MODIFICATIONS = True
