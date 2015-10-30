{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-green">
            <div class="panel-heading">
               <b>To-Do List</b>
            </div>
            <div class="panel-body">
                {% if not project_summary %}
                <p align="center"><b>No incomplete projects/tasks</b></p>
                {% else %}
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th width="60%">Project</th>
                                <th width="30%">Client</th>
                                <th style="width: 50px;text-align: center;">Tasks</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for row in project_summary %}
                            <tr>
                                <td><a href="/projects/view/{{ row.id }}">{{ row.name }}</a></td>
                                <td>{{ row.client_name }}</td>
                                <td style="text-align: center;">{{ row.task_count }}</td>
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
        <div class="panel panel-green">
            <div class="panel-heading">
               <b>Shopping List Summary</b>
            </div>
            <div class="panel-body">
                {% if not shopping_summary %}
                <p align="center"><b>Nothing on the list</b></p>
                {% else %}
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th width="75%">Store</th>
                                <th width="14%">Items</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for store in shopping_summary %}
                            <tr>
                            <td><a href="/house/shopping/{{ store.id }}">{{ store.name }}</a></td>
                            <td>{{ store.count }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
                {% endif %}
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-green">
            <div class="panel-heading">
               <b>Income vs Expenses - Last 6 Months</b>
            </div>
            <div class="panel-body">
                <div id="spending-chart"></div>
            </div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-green">
            <div class="panel-heading">
               <b>Current Month Time Entries</b>
            </div>
            <div class="panel-body">
                {% if not current_month_time %}
                <p align="center"><b>No time entries for the current month</b></p>
                {% else %}
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th width="50%">Client Name</th>
                                <th width="25%">Hours</th>
                                <th width="25%" style="text-align: right;">Estimated Income</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for row in current_month_time %}
                            <tr>
                                <td>{{ row.client_name }}</td>
                                <td>{{ row.total }}</td>
                                <td style="text-align: right;">${{ row.est_income|number_format(2) }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3" style="text-align: right;">${{ current_month_total|number_format(2) }}</th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                {% endif %}
            </div>
        </div>
    </div>
</div>
<script>
$(document).ready(function() {
    Morris.Area({
        element: 'spending-chart',
        data: {{ spending_summary.json|raw }},
        xkey: 'month',
        ykeys: [{{ spending_summary.cats|raw }}],
        labels: [{{ spending_summary.cats|raw }}],
        pointSize: 2,
        hideHover: 'auto',
        resize: true,
        preUnits: '$'
    });
});
</script>
{% endblock %}