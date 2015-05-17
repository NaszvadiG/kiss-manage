{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Update User Profile</b>
            </div>
            <div class="panel-body" >
                    <form role="form" id="user_profile" method="POST" action="/user/setProfile">
                        <input type="hidden" name="id" value="{{ id|default('0') }}">
                        <input type="hidden" name="add" value="{{ add|default('0') }}">
                        {% if message %}
                        <div class="alert alert-danger alert-dismissable">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                            {{ message|raw }}
                        </div>
                        {% endif %}
                        <fieldset>
                            <div class="form-group">
                                <label>Email Address</label>
                                <input class="form-control" placeholder="E-mail" name="email" type="email" autofocus value="{{ email }}">
                            </div>
                            <div class="form-group">
                                <label>First Name</label>
                                <input class="form-control" placeholder="First Name" name="first_name" type="text" value="{{ first_name }}">
                            </div>
                            <div class="form-group">
                                <label>Last Name</label>
                                <input class="form-control" placeholder="Last Name" name="last_name" type="text" value="{{ last_name }}">
                            </div>
                            <div class="form-group">
                                <label>New Password</label>
                                <input class="form-control" placeholder="Password" name="password" type="password" value="">
                            </div>
                            <div class="form-group">
                                <label>Confirm New Password</label>
                                <input class="form-control" placeholder="Password" name="password_confirm" type="password" value="">
                            </div>
                            <button class="btn btn-primary" type="submit">Save</button>
                        </fieldset>
                    </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}