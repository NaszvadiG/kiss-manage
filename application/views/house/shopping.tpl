{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-7">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Shopping List</b>
            </div>
            <div class="panel-body">
                <form role="form" id="select_store_form" method="POST" action="/house/shopping">
                    <div class="form-group container-fluid">
                        <label>Filter By Store&nbsp;</label>
                        <select class="form-control" name="store_id" id="select_store_id" style="width: 200px;" onchange="this.form.submit()">
                            {% for option in store_filter %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                </form>
                {% if not list %}
                <p align="center">Nothing to shop for!</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="shopping-list-table">
                        <thead>
                            <tr>
                                <th style="width: 30px;">&nbsp;</th>
                                <th width="50%">Item</th>
                                <th width="20%">Store</th>
                                <th width="15%">Date Added</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for item in list %}
                        <tr>
                            <td style="vertical-align: middle; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/house/shopping/{{ item.store_id }}/{{ item.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-check" href="/house/setShoppingItemPurchased/{{ item.store_id }}/{{ item.id }}"></a>
                            </td>
                            <td style="vertical-align: middle;">{{ item.name }}</td>
                            <td style="vertical-align: middle;">{{ item.store_name }}</td>
                            <td style="vertical-align: middle;">{{ item.created_date }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>
                </div>
                {% endif %}
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">
            {% if selected.id %}
                <b>Update Item</b>
            {% else %}
                <b>Add Item To List</b>
            {% endif %}
            </div>
            <div class="panel-body">
                <form role="form" id="add_item_form" method="POST" action="/house/editShoppingItem">
                    <input type="hidden" name="item_id" value="{{ selected.id }}">
                    <div class="form-group">
                        <label>Item</label>
                        <input class="form-control" placeholder="Enter Item" type="text" name="name" value="{{ selected.name }}" data-validation="required" data-validation-error-msg="Item name required">
                    </div>
                    <div class="form-group">
                        <label>Store&nbsp;</label>
                        <select class="form-control" name="store_id" id="store_id" style="width: 200px;" onchange="checkAddStore(">
                            <option>&nbsp;</option>
                            <option value="-1">+ Add Store +</option>
                            {% for option in store_options %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group" id="store_name_input" style="display: none;">
                        <label>Store Name</label>
                        <input class="form-control" placeholder="Enter New Store Name" type="text" name="store_name" value="">
                    </div>
                    <button type="submit" class="btn btn-primary">Save</button>&nbsp;
                    <button type="button" class="btn btn-default" id="clear_button">Clear</button>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
    $('#shopping-list-table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": false,
            "stateSave": true,
            "bLengthChange": false,
    });
    $("#store_id").on('change', function() {
        var store_id = $(this).val();
        if(store_id == -1) {
            $("#store_name_input").toggle(true);
        } else {
            $("#store_name_input").toggle(false);
        }
    });
    $("#clear_button").click(function(){
        $("#select_store_form").submit();
    });
});
</script>
{% endblock %}