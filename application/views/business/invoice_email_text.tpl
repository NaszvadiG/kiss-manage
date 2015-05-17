{% block content %}
{{ message }}

---------------------------------------------
Invoice Summary
---------------------------------------------
Invoice ID: {{ invoice_id }}
Issue date: {{ created_date }}
Amount: ${{ amount }}
Due: (Upon receipt)

A detailed invoice is attached as a PDF.

Thank you!
---------------------------------------------
{% endblock %}