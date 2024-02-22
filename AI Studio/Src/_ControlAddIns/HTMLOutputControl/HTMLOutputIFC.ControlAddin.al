controladdin "HTML Output_IFC"
{
    VerticalStretch = true;
    VerticalShrink = true;
    MinimumWidth = 250;
    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumHeight = 250;
    RequestedHeight = 350;

    Scripts = 'Src\_ControlAddIns\HTMLOutputControl\script\Main.js';
    StyleSheets = 'Src\_ControlAddIns\HTMLOutputControl\css\HTMLOutput.css';
    StartupScript = 'Src\_ControlAddIns\HTMLOutputControl\script\Startup.js';

    event OnInitialized()

    procedure SetHTMLValue(htmlvalue: Text);

}