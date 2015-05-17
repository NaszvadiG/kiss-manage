{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-5">
        <div class="well well-sm">
            <form method="POST">
                <div class="form-group">
                    <label>Start Date</label>
                    <input id="start_date" class="form-control" type="text" name="options[start_date]" style="width: 120px;" value="{{ options.start_date }}">
                </div>
                <div class="form-group">
                    <label>End Date</label>
                    <input id="end_date" class="form-control" type="text" name="options[end_date]" style="width: 120px;" value="{{ options.end_date }}">
                </div>
                <div class="form-group">
                    <label>Filter By</label>
                    <select class="form-control" name="options[filter][deductible]">
                        {% for option in deduct_options %}
                        {{ option|raw }}
                        {% endfor %}
                    </select>
                </div>
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">Go</button>
                </div>
            </form>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Expense Graph</b>
            </div>
            <div class="panel-body">
                <div id="spending-chart"></div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Expense Report</b>
            </div>
            <div class="panel-body">
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="report-table">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th>Category</th>
                                <th style="text-align:right;">Total&nbsp;&nbsp;&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for month, month_data in report %}
                            {% for ded, ded_data in month_data %}
                                {% for cat, total in ded_data %}
                                <tr>
                                <td>{{ month }}</td>
                                <td>{{ cat }}</td>
                                <td style="text-align:right">${{ total|number_format(2) }}</td>
                                </tr>
                                {% endfor %}
                            {% endfor %}
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="2" style="text-align:right">Totals: </th>
                                <th style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="/jquery/money.jquery.js"></script>
<script>
$(document).ready(function() {
    $("#start_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#end_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    Morris.Area({
        element: 'spending-chart',
        data: {{ graph.json|raw }},
        xkey: 'month',
        ykeys: [{{ graph.cats|raw }}],
        labels: [{{ graph.cats|raw }}],
        pointSize: 2,
        hideHover: 'auto',
        resize: true,
        preUnits: '$',
        xLabels: 'month'
    });
    $('#report-table').DataTable({
        "responsive": true,
        "pageLength": 25,
        "searching": true,
        "stateSave": true,
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
                .column(2)
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                } );
            // Total over this page
            page_total = api
                .column(2, {page: 'current'})
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                }, 0 );
            // Update footer
            var page_total_disp = $('<span>');
            var total_disp = $('<span>');
            page_total_disp.money(page_total);
            total_disp.money(total);
            $(api.column(2).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
        }
    });
});
</script>
{% endblock %}