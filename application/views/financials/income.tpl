{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Income</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected.id ? 'Update' : 'Add' }} Income Entry</h4>
                    <form role="form" id="edit_check_form" method="POST" action="/financials/setIncome">
                        <input type="hidden" name="id" value="{{ selected.id|default('0') }}">
                        <div class="table-responsive container-fluid">
                            <table class="table" id="incomes-edit-table">
                                <thead>
                                    <tr>
                                        <th>Invoice #</th>
                                        <th>Check #</th>
                                        <th>Paid Date</th>
                                        <th>Client</th>
                                        <th>Account</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="width: 130px;">
                                            <input class="form-control" style="width: 100px;" type="text" name="income[invoice_id]" placeholder="#101" value="{{ selected.invoice_id }}">
                                        </td>
                                        <td style="width: 130px;">
                                            <input class="form-control" style="width: 100px;" type="text" name="income[check_num]" placeholder="#111" value="{{ selected.check_num }}">
                                        </td>
                                        <td style="width: 130px;">
                                            <input id="paid_date" class="form-control" style="width: 100px;" type="text" name="income[paid_date]" value="{{ selected.paid_date }}" data-validation="required" data-validation-error-msg="Paid date required">
                                        </td>
                                        <td style="width: 200px;">
                                            <select class="form-control" name="income[client_id]">
                                                {% for option in client_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td style="width: 200px;">
                                            <select class="form-control" name="income[account_id]">
                                                {% for option in account_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td style="width: 100px;">
                                            <input class="form-control" type="text" name="income[total]" placeholder="0.00" value="{{ selected.total }}" data-validation="number" data-validation-allowing="float" data-validation-error-msg="Total required">
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
                <form role="form" id="filter_date_form" method="POST" action="/financials/income">
                    <div class="form-group table-responsive container-fluid">
                        <table class="table ">
                            <thead>
                                <tr>
                                    <th style="width: 150px;">Filter By Paid Date</th>
                                    <th>Filter By Client</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                         <input id="start_date" class="form-control" type="text" name="start_date" style="width: 120px;" value="{{ start_date }}" onchange="this.form.submit()">
                                    </td>
                                    <td>
                                        <select class="form-control" name="filter_client" onchange="this.form.submit()">
                                            <option value="0">- All -</option>
                                            {% for option in client_filters %}
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
                {% if not incomes %}
                <p align="center">No income found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="incomes-list-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Paid Date</th>
                                <th>Invoice #</th>
                                <th>Check #</th>
                                <th>Client</th>
                                <th>Account</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for income in incomes %}
                        <tr>
                            <td style="vertical-align: middle; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/financials/income/{{ income.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_income" income_id="{{ income.id }}"></a>
                            </td>
                            <td style="vertical-align: middle; width: 100px;" class="paid_date">{{ income.paid_date }}</td>
                            <td style="vertical-align: middle; width: 100px;">{{ income.invoice_id }}</td>
                            <td style="vertical-align: middle; width: 100px;">{{ income.check_num }}</td>
                            <td style="vertical-align: middle;" class="client">{{ income.client }}</td>
                            <td style="vertical-align: middle; width: 200px;">{{ income.account }}</td>
                            <td style="vertical-align: middle; width: 100px; text-align: right;">${{ income.total|number_format(2) }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="5" style="text-align:right">Totals: </th>
                                <th colspan="2" style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <form id="delete_income_form" method="POST" action="/financials/deleteIncome">
                    <input id="delete_income_id" type="hidden" name="income_id" value="">
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
    $('#incomes-list-table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": true,
            "stateSave": true,
            "bLengthChange": false,
            'aoColumnDefs': [{
                'bSortable': false,
                'aTargets': [0]
            }],
            "order": [[ 1, "desc" ]],
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
                    .column(6)
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    } );
                // Total over this page
                page_total = api
                    .column(6, {page: 'current'})
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    }, 0 );
                // Update footer
                var page_total_disp = $('<span>');
                var total_disp = $('<span>');
                page_total_disp.money(page_total);
                total_disp.money(total);
                $(api.column(5).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
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
    $("#paid_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".delete_income").click(function(){
        var income_id = $(this).attr('income_id');
        $("#delete_income_id").val(income_id);
        var paid_date = $(this).closest('tr').find('.paid_date').html();
        var client = $(this).closest('tr').find('.client').html();
        var check = "Are you sure you want to delete this income entry: " + client + " - " + paid_date;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_income_form").submit();
    });
});
</script>
{% endblock %}