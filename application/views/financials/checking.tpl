{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Checking</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected_check.id ? 'Update' : 'Add' }} Check</h4>
                    <form role="form" id="edit_check_form" method="POST" action="/financials/setCheck">
                        <input type="hidden" name="id" value="{{ selected_check.id|default('0') }}">
                        <div class="table-responsive container-fluid">
                            <table class="table" id="checks-edit-table">
                                <thead>
                                    <tr>
                                        <th>Check #</th>
                                        <th>Date</th>
                                        <th>Paid To</th>
                                        <th>Account</th>
                                        <th>Total</th>
                                        <th style="text-align: center;">Posted</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="width: 130px;">
                                            <input class="form-control" style="width: 100px;" type="text" name="check[check_num]" placeholder="#111" value="{{ selected_check.check_num }}" data-validation="required" data-validation-error-msg="Check number required">
                                        </td>
                                        <td style="width: 130px;">
                                            <input id="check_date" class="form-control" style="width: 100px;" type="text" name="check[check_date]" value="{{ selected_check.check_date }}" data-validation="required" data-validation-error-msg="Check date required">
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="check[paid_to]" placeholder="Gas Company" value="{{ selected_check.paid_to }}" data-validation="required" data-validation-error-msg="Paid to required">
                                        </td>
                                        <td style="width: 200px;">
                                            <select class="form-control" name="check[account_id]">
                                                {% for option in account_dropdown %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td style="width: 100px;">
                                            <input class="form-control" type="text" name="check[total]" placeholder="0.00" value="{{ selected_check.total }}" data-validation="number" data-validation-allowing="float" data-validation-error-msg="Total required">
                                        </td>
                                        <td style="width: 100px; vertical-align: middle; text-align: center">
                                            <input type="checkbox" name="check[posted]" value="1" {{ selected_check.posted ? 'checked' : '' }}>
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
                <form role="form" id="filter_date_form" method="POST" action="/financials/checking">
                    <div class="form-group table-responsive container-fluid">
                        <table class="table ">
                            <thead>
                                <tr>
                                    <th>Filter By Check Date</th>
                                    <th>Filter By Account</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                         <input id="start_date" class="form-control" type="text" name="start_date" style="width: 100px;" value="{{ start_date }}" onchange="this.form.submit()">
                                    </td>
                                    <td>
                                        <select class="form-control" name="filter_account" onchange="this.form.submit()">
                                            <option value="0">- All -</option>
                                            {% for option in account_filter %}
                                            {{ option|raw }}
                                            {% endfor %}
                                        </select>
                                    </td>
                                </tr>
                            </tbody>
                        </table>      
                    </div>
                </form>
                </div>
                </div>
                {% if not checks %}
                <p align="center">No checks found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="checks-list-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Check #</th>
                                <th>Date</th>
                                <th>Paid To</th>
                                <th>Account</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for check in checks %}
                        <tr>
                            <td style="vertical-align: middle; text-align: right; width: 30px;">
                                {% if check.posted == 0 %}
                                <a class="btn btn-success btn-circle fa fa-check post_check" check_id="{{ check.id }}"></a>&nbsp;
                                {% endif %}
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/financials/checking/{{ check.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_check" check_id="{{ check.id }}"></a>
                            </td>
                            <td style="vertical-align: middle; width: 100px;" class="check_num">{{ check.check_num }}</td>
                            <td style="vertical-align: middle; width: 100px;">{{ check.check_date }}</td>
                            <td style="vertical-align: middle;">{{ check.paid_to }}</td>
                            <td style="vertical-align: middle; width: 200px;" class="check_account">{{ check.account }}</td>
                            <td style="vertical-align: middle; width: 100px; text-align: right;">${{ check.total|number_format(2) }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4" style="text-align:right">Totals: </th>
                                <th colspan="2" style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <form id="delete_check_form" method="POST" action="/financials/deleteCheck">
                    <input id="delete_check_id" type="hidden" name="check_id" value="">
                </form>
                <form id="post_check_form" method="POST" action="/financials/postCheck">
                    <input id="post_check_id" type="hidden" name="check_id" value="">
                </form>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% include 'kiss_modal.tpl' %}
<script src="/jquery/money.jquery.js"></script>
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
    $('#checks-list-table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": true,
            "stateSave": true,
            "bLengthChange": false,
            'aoColumnDefs': [{
                'bSortable': false,
                'aTargets': [0]
            }],
            "order": [[ 2, "desc" ]],
            "footerCallback": function (row, data, start, end, display) {
                var api = this.api(), data;
                // Remove the formatting to get integer data for summation
                var parseVal = function (i) {
                    if(typeof i === 'string') {
                        i = i.replace(/[\$,]/g, '');
                    }
                    return Number(i);
                };
                // Total over all pages
                total = api
                    .column(5)
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    } );
                // Total over this page
                page_total = api
                    .column(5, {page: 'current'})
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    }, 0 );
                // Update footer
                var page_total_disp = $('<span>');
                var total_disp = $('<span>');
                page_total_disp.money(page_total);
                total_disp.money(total);
                $(api.column(4).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
            }
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
    $("#check_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".post_check").click(function(){
        var check_id = $(this).attr('check_id');
        $("#post_check_id").val(check_id);
        $("#post_check_form").submit();
    });
    $(".delete_check").click(function(){
        var check_id = $(this).attr('check_id');
        $("#delete_check_id").val(check_id);
        var check_num = $(this).closest('tr').find('.check_num').html();
        var account = $(this).closest('tr').find('.check_account').html();
        var check = "Are you sure you want to delete this check: " + check_num + " - " + account;
        $("#dialog-confirm").html(check);
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_check_form").submit();
    });
});
</script>
{% endblock %}