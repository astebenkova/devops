from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy
from app.forms import EmailForm


app = Flask(__name__)
app.config.from_object("app.config.Config")
db = SQLAlchemy(app)


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(128), unique=True, nullable=False)
    active = db.Column(db.Boolean(), default=True, nullable=False)

    def __init__(self, email):
        self.email = email


@app.route("/", methods=['GET', 'POST'])
def hello():
    msg = ""
    form = EmailForm()
    if form.validate_on_submit():
        email = request.form['email']
        record = User(email=email)
        exists = db.session.query(db.exists().where(User.email == email)).scalar()
        if not exists:
            db.session.add(record)
            db.session.commit()
            msg = "Thanks for your email, buddy! We will spam you later."
        else:
            msg = "This email already exists!"
    return render_template("results.html", form=form, message=msg)
