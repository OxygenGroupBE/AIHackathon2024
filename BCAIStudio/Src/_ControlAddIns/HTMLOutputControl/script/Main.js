function SetHTMLValue(htmlvalue) {
    var controlAddIn = document.getElementById('controlAddIn');
    if (!controlAddIn) {
        console.error('controlAddIn not found!')
        return;
    }

    if (!htmlvalue || htmlvalue === "") {
        htmlvalue = ""
    }

    controlAddIn.innerHTML = '<div class="divTable"><textarea readonly st>' + htmlvalue + '</textarea></div>';
}