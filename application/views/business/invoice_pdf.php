<html>
<head>
<style type="text/css">
.invoice-wrapper {
    font-family: "Helvetica Neue", Helvetica, Arial, Verdana, "Nimbus Sans L", sans-serif;
    font-size: .8em;
    width: 700px;
}
.heading-table, .small-table {
    display:block;
    height:auto;
    overflow:auto;
    border:none;
}
.heading-row, .small-row {
    display:block;
    height:auto;
    overflow:auto;
    border: none;
}
.heading-cell {
    border:none;
    float:left;
    display:inline-block;
    width:45%;
}
.small-cell {
    border: none;
    float:left;
    display:inline-block;
    width:50%;
}

.invoice-items {
    border-collapse: collapse;
    margin: 50px 0;
    width: 100%;
}
.invoice-items th {
    border-bottom: 1px solid #cccccc;
    border-right: 1px solid #cccccc;
    font-size: 0.8em;
    font-weight: bold;
    line-height: 1.1em;
    padding: 3px 10px 2px;
    text-align: left;
    vertical-align: top;
}
.invoice-items td {
    border-bottom: 1px solid #cccccc;
    border-right: 1px solid #cccccc;
    float: none;
    font-weight: normal;
    font-size: 0.8em;
    padding: 10px;
    text-align: left;
    vertical-align: top;
}
.invoice-items .first {
    padding-left: 5px; 
}
.invoice-items .last {
    border-right: none;
    padding-right: 10px; 
}
.invoice-items tr.row-0 td {
    background: #f6f6f6; 
}
.invoice-items tr.row-1 td {
    background: #ffffff; 
}
.invoice-items .item-date {
    text-align: left;
    width: 85px;
}
.invoice-items .item-qty {
    text-align: center;
    width: 50px;
}
.invoice-items .item-unit-price {
    text-align: center;
    white-space: nowrap;
    width: 50px;
}
.invoice-items .item-amount {
    font-weight: bold;
    text-align: right;
    white-space: nowrap;
    width: 65px; 
}
.invoice-summary th {
    border: 0px;
    color: #555555;
    padding: 2px 10px;
    text-align: right;
    padding-top: 20px;
}
.invoice-summary tr.total th {
    color: #222222;
    font-size: 1em;
    font-weight: bold;
    padding-top: 1.1em;
}
.invoice-summary tr.total th.total {
    padding-right: 5px;
    white-space: nowrap; 
}
.invoice-notes {
  
  border-top: 1px solid #cccccc;
  padding: 0 5px;
  margin: 0; 
}
* html .invoice-notes {
    overflow-x: hidden; 
}
.invoice-notes h3 {
    
    font-weight: bold;
    margin: 5px 0 10px; 
}
</style>
</head>
<body>
<div class="invoice-wrapper">
<div class="heading-table">
    <div class="heading-row">
        <div class="heading-cell">
            <div style="padding-left: 30px;"><img src="<?php echo $options['invoice_logo_url']; ?>" height="124" width="194"/></div>
        </div>
        <div class="heading-cell" style="text-align: right">
            <div class="small-table">
                <div class="small-row">
                    <div class="small-cell" style="width: 75%;">
                        <h3>INVOICE</h3>
                    </div>
                </div>
                <div class="small-row">
                    <div class="small-cell" style="width:46%">
                        <span style="color: #555; font-size: .75em; font-weight: normal; margin-right: 10px;">From</span>
                    </div>
                    <div class="small-cell" style="width:49%; padding-left: 10px; border-left: 1px solid #cccccc; text-align: left">
                        <?php echo $options['invoice_from']; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="heading-row">
        <div class="heading-cell" style="width: 100%; margin-bottom: 3px; margin-top: 3px;">
            &nbsp;
        </div>
    </div>
    <div class="heading-row">
        <div class="heading-cell">
            <div class="small-table">
                <div class="small-row">
                    <div class="small-cell" style="width:100px;; text-align: right; margin-right: 5px;">
                        <span style="color: #555; font-size: .75em; font-weight: normal; padding-right: 10px;">Invoice For</span>
                    </div>
                    <div class="small-cell" style="width:60%; padding-left: 10px; border-left: 1px solid #cccccc; text-align: left">
                        <b><?php echo $client['name']; ?></b><br>
                        <?php echo nl2br($client['address']); ?>
                    </div>
                </div>
            </div>
        </div>
        <div class="heading-cell" style="text-align: right">
            <div class="small-table">
                <div class="small-row">
                    <div class="small-cell" style="width:46%">
                        <span style="color: #555; font-size: .75em; font-weight: normal; padding-right: 10px;">Invoice ID</span>
                    </div>
                    <div class="small-cell" style="width:49%; padding-left: 10px; border-left: 1px solid #cccccc; text-align: left">
                        <?php echo $invoice['id']; ?>
                    </div>
                </div>
                <div class="small-row">
                    <div class="small-cell" style="width:46%">
                        <span style="color: #555; font-size: .75em; font-weight: normal; padding-right: 10px;">Issue Date</span>
                    </div>
                    <div class="small-cell" style="width:49%; padding-left: 10px; border-left: 1px solid #cccccc; text-align: left">
                        <?php echo $invoice['created_date']; ?>
                    </div>
                </div>
                <div class="small-row">
                    <div class="small-cell" style="width:46%">
                        <span style="color: #555; font-size: .75em; font-weight: normal; padding-right: 10px;">Due Date</span>
                    </div>
                    <div class="small-cell" style="width:49%; padding-left: 10px; border-left: 1px solid #cccccc; text-align: left">
                        Upon Receipt
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<br>
<table class="invoice-items" cellspacing="0" cellpadding="0" border="0">
    <thead class="invoice-items-header">
      <tr>
        <th class="item-date first">Date</th>
        <th class="item-description first">Description</th>
        <th class="item-qty">Hours</th>
        <th class="item-unit-price">Rate</th>
        <th class="item-amount last">Amount</th>
      </tr>
    </thead>
    <tbody class="invoice-rows">
        <?php 
        $i = 0;
        foreach($detail as $row) {
        ?>
        <tr class="row-<?php echo ($i++ % 2); ?>">
          <td class="item-date first"><?php echo $row['entry_date']; ?></td>
          <td class="item-description first">
            <?php echo nl2br($row['work_performed']); ?>
          </td>
          <td class="item-qty"><?php echo number_format($row['total_time']/60, 2); ?></td>
          <td class="item-unit-price">$<?php echo number_format($row['effective_rate'], 2); ?></td>
          <td class="item-amount last">$<?php echo number_format($row['entry_total'], 2); ?></td>
        </tr>
        <?php
        } ?>
    </tbody>
    <tfoot class="invoice-summary">   
        <tr class="total">
            <th>&nbsp;</th>
            <th>&nbsp;</th>
            <th>&nbsp;</th>
            <th class="total">Amount Due</th>
            <th class="total">$<?php echo number_format($invoice['amount'], 2); ?></th>
        </tr>
    </tfoot>
</table>
<div class="invoice-notes">
    <p class="notes">
    <?php echo $options['invoice_notes']; ?>
    </p>   
    <div style='clear:both;'></div>
</div>
</div>
</body>
</html>