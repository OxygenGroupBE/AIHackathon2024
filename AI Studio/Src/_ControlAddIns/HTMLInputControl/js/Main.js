function SetHTMLValue(htmlvalue) {
    var controlAddIn = document.getElementById('controlAddIn');
    if (!controlAddIn) {
        console.error('controlAddIn not found!')
        return;
    }

    if (!htmlvalue || htmlvalue === "") {
        htmlvalue = ""
    }

    //define the input wysiwyg html textbox : visible action: bold - underline - italic - color for RDLC html compatibility
    controlAddIn.innerHTML = '<div id="input" style="height: 300px" data-tiny-editor data-formatblock="no" data-fontname="no" data-bold="no" data-italic="no" data-underline="no" data-forecolor="no" data-justifyleft="no" ' +
        'data-justifycenter="no" data-justifyright="no" data-insertorderedlist="no" data-insertunorderedlist="no" ' +
        'data-outdent="no" data-indent="no" data-remove-format="no">' +
        htmlvalue + '</div>';

    // allow paste text but only as plain text to prevent html tags that are not supported bij RDLC reports
    const myInput = document.getElementById('input');
    myInput.addEventListener("paste", function (e) {
        // cancel paste
        e.preventDefault();

        // get text representation of clipboard
        var text = (e.originalEvent || e).clipboardData.getData('text/plain');

        // insert text manually
        document.execCommand("insertHTML", false, text);
    });

    //load the bundle.js javascript(wysiwyg editor code) before the end of the body tag in the controladdin iframe
    var script = document.createElement('script');
    var wysiwyg = Microsoft.Dynamics.NAV.GetImageResource('Src/_ControlAddIns/HTMLInputControl/js/bundle.js');
    //var wysiwyg = Microsoft.Dynamics.NAV.GetImageResource('bundle.js');
    //wysiwyg = wysiwyg.replace('bundle.js', 'Src\_ControlAddIns\HTMLInputControl\js\bundle.js');
    script.src = wysiwyg;
    document.body.appendChild(script);

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', null);
}


function PassHTMLValueToBC() {
    var controlAddIn = document.getElementById('input');

    if (!controlAddIn) {
        console.error('controlAddIn not found!')
        return;
    }

    //remove html tags (when copy paste html would be possible - but for now only paste plain-text is possible)
    var htmlvalue = controlAddIn.innerHTML;
    htmlvalue = htmlvalue.replace(/<\/?span[^>]*>/g, "");
    htmlvalue = htmlvalue.replace(/<\/?div[^>]*>/g, "");
    htmlvalue = htmlvalue.replace(/<\/?p[^>]*>/g, "<br>");
    htmlvalue = htmlvalue.replace(/style="(.*?)"/gm, "");
    htmlvalue = htmlvalue.replace(/&amp;/g, "&");
    htmlvalue = htmlvalue.replace(/&nbsp;/g, ' ');

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('SetReturnValue', [htmlvalue]);

}




