{% block content %}
<div class="table-responsive">
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Week</th>
                <th>Time</th>
            </tr>
        </thead>
        <tbody>
            {% for row in rows %}
            <tr>
                <td>{{ loop.index }}</td>
                <td>{{ row.total|number_format(2) }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
</div>
<button class="btn btn-sm btn-primary" type="button" onClick="closePopover('{{ client_id }}-{{ month }}')">Close</button>
{% endblock %}