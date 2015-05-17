{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-4">
        <div class="panel panel-green">
            <div class="panel-heading">
               <b>Shopping List Summary</b>
            </div>
            <div class="panel-body">
                {% if not shopping_summary %}
                <b>Nothing on the list</b>
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