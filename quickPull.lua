local args = { ... };local response = http.get(args[1]);local file = fs.open(args[2], "w");file.write(response.readAll());file.close();response.close();