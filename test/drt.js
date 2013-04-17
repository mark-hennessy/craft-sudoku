<script>
  // only run if testRunner is defined -- we're in DRT
  if (window.testRunner) {

    // Don't dump the structure. Just the text of the output plus console output
    testRunner.dumpAsText();

    // Don't finish when layout is done. Instead, wait to be notified
    testRunner.waitUntilDone();

    // listen for messages from the test harness
    window.addEventListener("message", receiveMessage, false);

    // listen for unhandled exceptions
    window.addEventListener('error', onError);
  }

  // if there is an unhandled exception, tell DRT we're done
  function onError(event) {
    testRunner.notifyDone();
  }

  // if the test harness sends a done message, tell DRT we're done
  function receiveMessage(event) {
    if(event.data == 'unittest-suite-done') {
      testRunner.notifyDone();
    }
  }
</script>