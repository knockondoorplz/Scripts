// Popup script (popup.js)

// Listen for messages from the background script
chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (message.action === "appendToTxtFile") {
      let selectedText = message.selectedText;
      if (selectedText) {
        // Implement file handling logic here using appropriate APIs
        appendToTxtFile(selectedText);
      }
    }
  });
  
  // Function to append text to a file
  function appendToTxtFile(text) {
    // Implement your file handling logic here
    // This may involve using the File System Access API or other appropriate methods
    console.log("Text to append:", text);
    // Example: Use File System Access API
    // Use window.showOpenFilePicker() and handle the file write operation
    // Example: Native File System API
    // Use handle.createWritable() to write text to the selected file
  }
  