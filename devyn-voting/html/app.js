let elections = "";
window.addEventListener("message", function(event) {
    const data = event.data;
    const action = data.action;
    elections = data.elections;

    if (action == "open") {

        $.each(elections, function(index, value) {
            $(".elections").append(`<div class="election"><div class="election-header"><p>${index}</p></div><div class="nominees${index}"></div></div>`);
            $.each(value, function(key, name) {
                $(".nominees"+index).append(`
                <div class="form-check form-${index}">
                    <input class="form-check-input" type="radio" name="election-${index}" id="nominee${key}${index}" value="${key}">
                    <label class="form-check-label" for="nominee${key}">${name}</label>
                </div>`);
                
            });
        });

        $(".vote-buttons").append(`<button type="button" class="btn btn-success vote-submit">Vote!</button>`);

        if (data.admin) 
            $(".vote-buttons").append(`<button type="button" class="btn btn-danger vote-admin">Admin</button>`);

        $(".voting-container").fadeIn(500);
    }
});

$(document).on('click', '.vote-submit', function(e){
    e.preventDefault();
    var votes = {}
    $.each(elections, function(index, value) {
        $.each(value, function(key, name) {
            if($('#nominee'+key+index).is(':checked')) {
                votes[index] = name;
            }
        });
    });
    
    $(".voting-container").fadeOut(500);
    $.post('https://devyn-voting/vote', JSON.stringify({votes : votes}));
    document.getElementById("vote-wipe").innerHTML = '';
});

$(document).on('click', '.vote-admin', function(e){
    e.preventDefault();
    $.post('https://devyn-voting/admin'); 
});

document.onkeyup = function (event) {
    event = event || window.event;
    if (event.key == "Escape") {
        $(".voting-container").fadeOut(500);
        document.getElementById("vote-wipe").innerHTML = '';
        $.post('https://devyn-voting/close'); 
    }
};