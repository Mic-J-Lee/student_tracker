// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require_tree .

function showHideAttendance() {
  const toggleMouseover = document.getElementById("toggleMouseover")
  const attendanceForm = document.getElementById("attendanceForm")
  attendanceForm.style.display === "none" ? attendanceForm.style.display = "block" : attendanceForm.style.display = "none"
  toggleMouseover.parentNode.style.display === "none" ? toggleMouseover.parentNode.style.display = "block" : toggleMouseover.parentNode.style.display = "none"
}

function checkChildButton(div) {
  const toggleMouseover = document.getElementById("toggleMouseover")
  if (toggleMouseover.innerHTML == 'ON') div.firstElementChild.checked = true
}

function toggleMouseover(button) {
  if (button.innerHTML == 'ON') button.innerHTML = 'OFF'
  else button.innerHTML = 'ON'
}
