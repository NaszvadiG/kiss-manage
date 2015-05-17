{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Misc Expenses</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected.id ? 'Update' : 'Add' }} Expense</h4>
                    <form role="form" id="edit_form" method="POST" action="/business/setMiscExpense">
                        <input type="hidden" name="id" value="{{ selected.id|default('0') }}">
                        <div class="table-responsive container-fluid">
                            <table class="table" id="checks-edit-table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Description</th>
                                        <th>Category</th>
                                        <th>Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="width: 130px;">
                                            <input id="created_date" class="form-control" style="width: 100px;" type="text" name="post_array[created_date]" value="{{ selected.created_date|date('Y-m-d') }}" data-validation="required" data-validation-error-msg="Date required">
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="post_array[description]" placeholder="Mileage to ...." value="{{ selected.description }}" data-validation="required" data-validation-error-msg="Description required">
                                        </td>
                                        <td style="width: 200px;">
                                            <select class="form-control" name="post_array[category_id]">
                                                {% for option in category_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td style="width: 100px;">
                                            <input class="form-control" type="text" name="post_array[amount]" placeholder="0" value="{{ selected.amount }}" data-validation="required" data-validation-error-msg="Amount required">
                                        </td>
                                    <tr>
                                    <tr>
                                        <td colspan="7" style="text-align: left">
                                            <button type="submit" class="btn btn-primary">Save</button>&nbsp;
                                            <button type="button" class="btn btn-default" id="clear_button">Clear</button>&nbsp;
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </form>
                </div>
                <div class="row">
                <div class="col-md-4">
                <form role="form" id="filter_date_form" method="POST" action="/business/miscExpense">
                    <div class="form-group table-responsive container-fluid">
                        <table class="table ">
                            <thead>
                                <tr>
                                    <th>Filter By Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                         <input id="start_date" class="form-control" type="text" name="start_date" style="width: 100px;" value="{{ start_date }}" onchange="this.form.submit()">
                                    </td>
                                </tr>
                            </tbody>
                        </table>      
                    </div>
                </form>
                </div>
                </div>
                {% if not rows %}
                <p align="center">No miscellaneous expenses found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="data_row_table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Date</th>
                                <th>Description</th>
                                <th>Category</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for row in rows %}
                        <tr>
                            <td style="vertical-align: middle; text-align: right; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/business/miscExpense/{{ row.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_row" row_id="{{ row.id }}"></a>
                            </td>
                            <td style="vertical-align: middle; width: 100px;" class="row_date">{{ row.created_date }}</td>
                            <td style="vertical-align: middle;" class="row_desc">{{ row.description }}</td>
                            <td style="vertical-align: middle; width: 200px;" class="row_category">{{ row.category }}</td>
                            <td style="vertical-align: middle; width: 100px; text-align: right;">{{ row.amount }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>
                </div>
                <form id="delete_row_form" method="POST" action="/business/deleteMiscExpense">
                    <input id="delete_row_id" type="hidden" name="row_id" value="">
                </form>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% include 'kiss_modal.tpl' %}
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
    $('#data_row_table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": true,
            "stateSave": true,
            "bLengthChange": false,
            'aoColumnDefs': [{
                'bSortable': false,
                'aTargets': [0]
            }],
            "order": [[ 1, "desc" ]]
    });
    $("#start_date").datepicker({
        dateFormat: "yy-mm-dd",
        beforeShow: function (textbox, instance) {
            instance.dpDiv.css({
                    marginTop: (-textbox.offsetHeight) + 'px',
                    marginLeft: textbox.offsetWidth + 'px'
            });
        }
    });
    $("#created_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".delete_row").click(function(){
        var row_id = $(this).attr('row_id');
        $("#delete_row_id").val(row_id);
        var row_date = $(this).closest('tr').find('.row_date').html();
        var row_desc = $(this).closest('tr').find('.row_desc').html();
        var check = "Are you sure you want to delete this expense: " + row_date + " - " + row_desc;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_row_form").submit();
    });
});
</script>
{% endblock %}