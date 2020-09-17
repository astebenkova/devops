from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import InputRequired, Regexp, Length


class EmailForm(FlaskForm):
    email = StringField('Email', [InputRequired(), Regexp(r'^[^@]+@[^@]+\.[^@]+$', message="Invalid email"),
                                  Length(max=35, message="Invalid email length")])
    submit = SubmitField('Just press it, stupid')
