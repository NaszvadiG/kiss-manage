<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>{{ header_data.title }}</title>
    <!-- Bootstrap Core CSS -->
    <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- MetisMenu CSS -->
    <link href="/metisMenu/metisMenu.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="/css/sb-admin-2.css" rel="stylesheet">
    <!-- Morris Charts CSS -->
    <link href="/morrisjs/morris.css" rel="stylesheet">
    <!-- Custom Fonts -->
    <link href="/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <script src="/jquery/jquery.min.js"></script>
    <!-- Bootstrap Core JavaScript -->
    <script src="/bootstrap/js/bootstrap.min.js"></script>
    <!-- Metis Menu Plugin JavaScript -->
    <script src="/metisMenu/metisMenu.min.js"></script>
    <!-- Morris Charts JavaScript -->
    <script src="/raphael/raphael-min.js"></script>
    <script src="/morrisjs/morris.min.js"></script>
    <!-- DataTables JavaScript -->
    <script src="/datatables/js/jquery.dataTables.min.js"></script>
    <script src="/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.min.js"></script>
    <!-- Custom Theme JavaScript -->
    <script src="/js/sb-admin-2.js"></script>
    <!-- Jquery UI -->
    <link rel="stylesheet" href="/jquery-ui/jquery-ui.min.css">
    <script src="/jquery-ui/jquery-ui.min.js"></script>
    <!-- Form validation (http://formvalidator.net) -->
    <script src="/form-validator/jquery.form-validator.min.js"></script>
    <style>
        .dataTables_filter {
           width: 50%;
           float: right;
           text-align: right;
        }
        .dataTables_paginate  {
           float: right;
           text-align: right;
        }
        .dataTable th, .dataTable td {
            max-width: 200px;
            /*min-width: 70px; */
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .glyphicon.spinning {
            animation: spin 1s infinite linear;
            -webkit-animation: spin2 1s infinite linear;
        }
        @keyframes spin {
            from { transform: scale(1) rotate(0deg);}
            to { transform: scale(1) rotate(360deg);}
        }
        @-webkit-keyframes spin2 {
            from { -webkit-transform: rotate(0deg);}
            to { -webkit-transform: rotate(360deg);}
        }
    </style>
</head>
<body>
<div id="wrapper">
    <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="/">{{ header_data.navbar_brand }}</a>
        </div>
        <ul class="nav navbar-top-links navbar-right">
            <li class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                    Hello&nbsp;{{ header_data.first_name }}&nbsp;
                    <i class="fa fa-user fa-fw"></i><i class="fa fa-caret-down"></i>
                </a>
                <ul class="dropdown-menu dropdown-user">
                    <li><a href="/user/profile"><i class="fa fa-user fa-fw"></i> User Profile</a></li>
                    <li class="divider"></li>
                    <li><a href="/logout"><i class="fa fa-sign-out fa-fw"></i> Logout</a></li>
                </ul>
                <!-- /.dropdown-user -->
            </li>
            <!-- /.dropdown -->
        </ul>
        <!-- /.navbar-top-links -->
        <div class="navbar-default sidebar" role="navigation">
            <div class="sidebar-nav navbar-collapse">
                <ul class="nav" id="side-menu">
                    <li>
                        <a href="/"><i class="fa fa-dashboard fa-fw"></i> Dashboard</a>
                    </li>
                    <li{% if(header_data.selected_menu == 'business') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-linux fa-fw"></i> Business<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li>
                                <a href="/business/time">- Time Tracking</a>
                            </li>
                            <li>
                                <a href="/business/invoicing">- Invoicing</a>
                            </li>
                            <li>
                                <a href="/business/miscExpense">- Misc Expenses</a>
                            </li>
                        </ul>
                    </li>
                    <li{% if(header_data.selected_menu == 'house') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-home fa-fw"></i> Household<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li>
                                <a href="/house/shopping">- Shopping List</a>
                            </li>
                        </ul>
                    </li>
                    <li{% if(header_data.selected_menu == 'financials') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-dollar fa-fw"></i> Financials<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li>
                                <a href="/financials/receipts">- Receipts</a>
                            </li>
                            <li>
                                <a href="/financials/utilities">- Utilities</a>
                            </li>
                            <li>
                                <a href="/financials/checking">- Checking</a>
                            </li>
                            <li>
                                <a href="/financials/income">- Income</a>
                            </li>
                            <li>
                                <a href="/financials/taxes">- Taxes</a>
                            </li>
                        </ul>
                    </li>
                    <li{% if(header_data.selected_menu == 'reporting') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-bar-chart-o fa-fw"></i> Reporting<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li>
                                <a href="/reporting/expenses">- Expenses</a>
                            </li>
                            <li>
                                <a href="/reporting/income">- Income & Time</a>
                            </li>
                            <li>
                                <a href="/reporting/utility">- Utility Usage</a>
                            </li>
                        </ul>
                    </li>
                    <li{% if(header_data.selected_menu == 'media') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-film fa-fw"></i> Media<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li{% if(header_data.selected_submenu == 'tv') %} class="active" {% endif %}>
                                <a href="#">TV<span class="fa arrow"></span></a>
                                <ul class="nav nav-third-level">
                                    <li>
                                        <a href="/media/tv">- View All TV</a>
                                    </li>
                                    <li>
                                        <a href="/media/pendingTv">- Pending TV</a>
                                    </li>
                                    <li>
                                        <a href="/media/editTv">- Add TV Show</a>
                                    </li>
                                </ul>
                                <!-- /.nav-third-level -->
                            </li>
                            <li>
                                <a href="/media/movies">- Movies</a>
                            </li>
                        </ul>
                    </li>
                    <li{% if(header_data.selected_menu == 'manage') %} class="active" {% endif %}>
                        <a href="#"><i class="fa fa-wrench fa-fw"></i> Manage<span class="fa arrow"></span></a>
                        <ul class="nav nav-second-level">
                            <li>
                                <a href="/manage/clients">- Clients</a>
                            </li>
                            <li>
                                <a href="/manage/accounts">- Accounts</a>
                            </li>
                            <li>
                                <a href="/manage/categories">- Receipt Categories</a>
                            </li>
                            <li>
                                <a href="/manage/utilityCategories">- Utility Categories</a>
                            </li>
                            <li>
                                <a href="/manage/taxCategories">- Tax Categories</a>
                            </li>
                            <li>
                                <a href="/user/manageUsers">- Users</a>
                            </li>
                            <li>
                                <a href="/manage/config">- Configuration</a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <div id="page-wrapper">
        &nbsp;
        {% if header_data.status|default and header_data.message|default %}
        <div class="row">
            <div class="col-md-6">
                <div class="alert alert-{{ header_data.status }} alert-dismissable">
                    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                    {{ header_data.message }}
                </div>
            </div>
        </div>
        {% endif %}
        {% block content %}{% endblock %}
    </div>
</div>
</body>
</html>