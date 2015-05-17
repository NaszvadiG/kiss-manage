{% block content %}
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>INVOICE</title>
</head>
<body bgcolor="F0F0EF">
    <table cellspacing="0" cellpadding="0" border="0" width="100%" id="invoice_email" style="background:#F0F0EF;width:100%;margin:0px auto;padding:20px 0px 40px;font-size:13px;line-height:16px;font-family:Helvetica, Arial, sans-serif;color:#222;">
        <tr>
            <td bgcolor="#F0F0EF">
                <table cellspacing="0" cellpadding="0" border="0" width="500" id="invoice_email_container" style="margin:0px auto;padding:0px 20px;font-size:13px;line-height:16px;">
                    <tr>
                        <td>
                            <table cellspacing="0" cellpadding="20" width="460" style="border:1px solid #D7D7D7; margin:0 0 10px;background:white;">
                                <tr>
                                    <td>
                                        <img id="low-res-logo" src="http://portal.careydrive.com/images/thumbnail.png" style="padding:0 0 20px;margin:0px;max-height:80px">
                                        <p style="margin:0px 0px 10px;"></p>
                                        <p>{{ message }}</p>
                                        <p>---------------------------------------------
                                        <br>Invoice Summary
                                        <br>---------------------------------------------
                                        <br>Invoice ID: {{ invoice_id }}
                                        <br>Issue date: {{ created_date }}
                                        <br>Amount: ${{ amount }}
                                        <br>Due: Upon receipt
                                        </p>
                                        <p>A detailed invoice is attached as a PDF.</p>
                                        <p>Thank you!
                                        <br>---------------------------------------------
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
{% endblock %}