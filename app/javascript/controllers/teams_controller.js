import { Controller } from "@hotwired/stimulus"

document.querySelectorAll('#add-user-btn, #add-team-btn').forEach(function(button) {
    button.addEventListener('click', function() {
        if (button.id === 'add-user-btn') {
            document.getElementById('invite-user-popup').classList.remove('hidden');
        } else if (button.id === 'add-team-btn') {
            document.getElementById('add-team-popup').classList.remove('hidden');
        }
    });
});


document.querySelectorAll('#user-cancel-btn, #cancel-btn-user, #team-cancel-btn, #cancel-btn-team')
    .forEach(function(button) {
        button.addEventListener('click', function() {
            if (button.id === 'user-cancel-btn' || button.id === 'cancel-btn-user') {
                document.getElementById('invite-user-popup').classList.add('hidden');
            } else if (button.id === 'team-cancel-btn' || button.id === 'cancel-btn-team') {
                document.getElementById('add-team-popup').classList.add('hidden');
            }
        });
    });
    
const createFileUploadComponent = (containerId, labelText) => {
    const container = document.getElementById(containerId);

    container.innerHTML = `
        <div class="flex flex-col gap-4 items-start justify-center w-full">
            <div class="flex flex-row gap-2 justify-between w-full">
                <label class="text-sm">${labelText}</label>
                <label class="text-sm text-[#E0E0E0]" id="${containerId}-file-label">No file chosen</label>
            </div>
            <div id="${containerId}-choose-file-div" class="flex gap-4 justify-center p-4 w-full border border-dashed border-primary rounded cursor-pointer">
                <span class="icon icon-upload h-4 w-4"></span>
                <p class="text-sm text-primary">Choose File</p>
            </div>
            <input type="file" id="${containerId}-file-input" class="hidden" />
        </div>
    `;

    document.getElementById(`${containerId}-choose-file-div`).addEventListener('click', () =>
        document.getElementById(`${containerId}-file-input`).click()
    );

    document.getElementById(`${containerId}-file-input`).addEventListener('change', (event) => {
        const fileName = event.target.files[0]?.name || 'No file chosen';
        document.getElementById(`${containerId}-file-label`).textContent = fileName;
    });
};

createFileUploadComponent('upload-csv', 'Upload CSV');
createFileUploadComponent('upload-your-logo', 'Upload Your Logo');
    
    