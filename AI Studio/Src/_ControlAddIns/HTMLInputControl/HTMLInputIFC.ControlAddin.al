controladdin "HTML Input_IFC"
{
    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumWidth = 250;
    VerticalStretch = true;
    VerticalShrink = true;
    MinimumHeight = 25;
    RequestedHeight = 350;

    Scripts = 'Src\_ControlAddIns\HTMLInputControl\js\Main.js';
    StyleSheets = 'Src\_ControlAddIns\HTMLInputControl\css\HTMLInput.css',
                  'Src\_ControlAddIns\HTMLInputControl\css\all.css';
    StartupScript = 'Src\_ControlAddIns\HTMLInputControl\js\Startup.js';
    Images = 'Src\_ControlAddIns\HTMLInputControl\js\bundle.js',
             'Src\_ControlAddIns\HTMLInputControl\webfonts\fa-solid-900.ttf';

    procedure SetHTMLValue(htmlvalue: Text);

    procedure PassHTMLValueToBC();

    event OnInitialized();

    event ControlAddInReady();

    event SetReturnValue(ReturnHTMLValue: text);
}