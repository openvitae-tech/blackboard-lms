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
    
const createFileUploadComponent = (containerId, labelText) => {
    const container = document.getElementById(containerId);

    container.innerHTML = `
        <div class="flex flex-col gap-4 items-start justify-center w-full">
            <div class="flex flex-row gap-2 justify-between w-full">
                <label class="text-sm">${labelText}</label>
                <label class="text-sm text-[#E0E0E0]" id="${containerId}-fileLabel">No file chosen</label>
            </div>
            <div id="${containerId}-chooseFileDiv" class="flex gap-4 justify-center p-4 w-full border border-dashed border-primary rounded cursor-pointer">
                <span class="icon icon-upload h-4 w-4"></span>
                <p class="text-sm text-primary">Choose File</p>
            </div>
            <input type="file" id="${containerId}-fileInput" class="hidden" />
        </div>
    `;

    document.getElementById(`${containerId}-chooseFileDiv`).addEventListener('click', () =>
        document.getElementById(`${containerId}-fileInput`).click()
    );

    document.getElementById(`${containerId}-fileInput`).addEventListener('change', (event) => {
        const fileName = event.target.files[0]?.name || 'No file chosen';
        document.getElementById(`${containerId}-fileLabel`).textContent = fileName;
    });
};

createFileUploadComponent('uploadCSV', 'Upload CSV');
createFileUploadComponent('uploadYourLogo', 'Upload Your Logo');
