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
                    <select class="form-control" name="options[filter][client_id]">
                        <option value="0">-None-</option>
                        {% for option in client_options %}
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
               <b>Time Graph</b>
            </div>
            <div class="panel-body">
                <div id="time-chart"></div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Time Report</b>
            </div>
            <div class="panel-body">
                {% if not report %}
                <b>No report data</b>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="report-table">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th>Client</th>
                                <th style="text-align:right;">Total Hours&nbsp;&nbsp;&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for month, month_data in report %}
                            {% for client, totals in month_data %}
                                <tr>
                                <td>{{ month }}</td>
                                <td>{{ client }}</td>
                                <td style="text-align:right;">{{ totals.total|number_format(2) }}</td>
                                </tr>
                            {% endfor %}
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="2" style="text-align:right;">Totals: </th>
                                <th style="text-align:right;"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                {% endif %}
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
        element: 'time-chart',
        data: {{ graph.json|raw }},
        xkey: 'month',
        ykeys: [{{ graph.cats|raw }}],
        labels: [{{ graph.cats|raw }}],
        pointSize: 2,
        hideHover: 'auto',
        resize: true,
        preUnits: '',
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
            // Total hours over all pages
            total_hours = api
                .column(2)
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                } );
            // Total hours over this page
            page_total_hours = api
                .column(2, {page: 'current'})
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                }, 0 );

            // Update footer
            $(api.column(2).footer()).html(page_total_hours.toFixed(2) +' ('+total_hours.toFixed(2)+')');
        }
    });
});
</script>
{% endblock %}