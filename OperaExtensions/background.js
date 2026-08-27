// Background script (background.js)

// Event listener when extension is installed or updated
chrome.runtime.onInstalled.addListener(function() {
  // Create context menu item
  chrome.contextMenus.create({
    id: "addToCollector",
    title: "Collect",
    contexts: ["selection"] // Show menu item when text is selected
  });
});

// Listen for clicks on the context menu item
chrome.contextMenus.onClicked.addListener(function(info, tab) {
  if (info.menuItemId === "addToCollector") {
    // Send message to popup script to handle file appending
    chrome.runtime.sendMessage({ action: "appendToTxtFile", selectedText: info.selectionText });
  }
});
