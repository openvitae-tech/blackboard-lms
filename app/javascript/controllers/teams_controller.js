import { Controller } from "@hotwired/stimulus"

document.querySelectorAll('#addUserBtn, #addTeamBtn').forEach(function(button) {
    button.addEventListener('click', function() {
        if (button.id === 'addUserBtn') {
            document.getElementById('inviteUserPopup').classList.remove('hidden');
        } else if (button.id === 'addTeamBtn') {
            document.getElementById('addTeamPopup').classList.remove('hidden');
        }
    });
});


document.querySelectorAll('#userCancelBtn, #cancelBtnUser, #teamCancelBtn, #cancelBtnTeam')
    .forEach(function(button) {
        button.addEventListener('click', function() {
            if (button.id === 'userCancelBtn' || button.id === 'cancelBtnUser') {
                document.getElementById('inviteUserPopup').classList.add('hidden');
            } else if (button.id === 'teamCancelBtn' || button.id === 'cancelBtnTeam') {
                document.getElementById('addTeamPopup').classList.add('hidden');
            }
        });
    });