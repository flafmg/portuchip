function convertToHex(inputFileName, outputFileName)
  local inputFile = io.open(inputFileName, "rb")
  if not inputFile then
    print("erro ao abrir o arquivo de entrada")
    return
  end

  local bytes = inputFile:read("*all")
  inputFile:close()

  local outputFile = io.open(outputFileName, "w")
  if not outputFile then
    print("erro ao abrir o arquivo de saida")
    return
  end

  for i = 1, #bytes do
    outputFile:write(string.format("%02X ", string.byte(bytes, i)))
  end

  outputFile:close()

  print("conversão concluida com sucesso")
end

io.write("digite o nome do arquivo de entrada: ")
local inputFileName = io.read()

io.write("digite o nome do arquivo de saída: ")
local outputFileName = io.read()

convertToHex(inputFileName, outputFileName)

