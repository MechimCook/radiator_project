# Instructions
 run `iex -S mix` from withen the app dirrectory
 then `App.run(file_name)`

 where `file_name` is the name of a file in the same directory as the app

# problems
  was not able to get the correct number of bytes from the files so the math for the CHECKSUM is wrong

# optomizations
   • when reformatting the file you could set each chunk as 20 except for the last remainder.
   • use web sockets to limit the requests and keep the device up to date without the device needing to request updated changes


# Questions and Answers
• Describe how you would accomplish updating 100+ devices with the same firmware.
  • If I was given a list of the devices addresses I would stream the file running all same steps for just 1 device asynchronously and report any failures to an error reporting serves like sentry and output the fails to a file to follow up on.  

• Imagine the devices respond to messages over a different channel than an HTTP response. For example, imagine the server responds to every valid message to a device with 200, and the device’s actual response arrives asynchronously over a websocket. What architecture would you use?
  • I would use Phoenix sockets as it does a lot for you and it should allow for better communication between the device and server

• In addition to updating the firmware for 100+ devices, imagine each device takes ∼30 seconds to respond to each message. Would this change anything?
 •Yes if the devices took ∼30 seconds to respond to each message I would optimize for each chunk to be 20 bytes as much as possible.

• Imagine that in addition to performing firmware updates to devices over a REST endpoint, you also need to communicate with devices over other protocols like MQTT, CoAP, or a custom protocol over TCP. How could your design accommodate this?
  • I would switch HTTPoison with a MQTT or CoAP Client and accommodate for whatever requests the device accepts
