programa
{
	inclua biblioteca Teclado
	inclua biblioteca Matematica
	inclua biblioteca Graficos
	inclua biblioteca Util
	inclua biblioteca Tipos
	inclua biblioteca Texto
	inclua biblioteca Arquivos

	
	const inteiro hz = 60
	const inteiro instrucoes_por_frame = 20
		
	inteiro memoria[4096]
	logico tela[64][32]
	logico teclado[16]

	inteiro stack[16]
	inteiro v[16] // registradores V
	inteiro pc = 0x200 //program counter
	inteiro sp = 0 // stack pointer
	inteiro i = 0

	inteiro dt = 0
	inteiro st = 0

	logico evento_tecla = falso
	inteiro tecla_pressionada = 0

	inteiro opcode

	inteiro nnn
	inteiro nn
	inteiro n
	inteiro x
	inteiro y

	inteiro fonte[] = {
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80  // F
	}
	funcao carregar_fonte(){
		para(inteiro i = 0; i < 80; i++){
			memoria[i] = fonte[i]
		}
	}

	funcao abrir_rom(cadeia caminho){
		inteiro rom_endereco = Arquivos.abrir_arquivo(caminho, 0)
		cadeia rom_cadeia = ""
		enquanto(nao Arquivos.fim_arquivo(rom_endereco)){
			rom_cadeia += Arquivos.ler_linha(rom_endereco)
		}

		//extrair bytes
		inteiro n_caracteres = Texto.numero_caracteres(rom_cadeia)
		inteiro index = 0x200
		para(inteiro i = 0; i < n_caracteres; i += 3){
			memoria[index] = Tipos.cadeia_para_inteiro(Texto.extrair_subtexto(rom_cadeia, i, i+2), 16)
			index++
		}
		
	}

	funcao ver_memoria(){
		escreva("   ADDR  | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 0A | 0B | 0C | 0D | 0E | 0F\n")
		escreva("-----------------------------------------------------------------------------------------\n")
		
		para(inteiro i = 0; i < 4096; i += 16){
			cadeia ns[16]
			para(inteiro j = 0; j < 16; j++){
				ns[j] = hex2(memoria[i+j])
			}
			escreva(hex(i), " | ", ns[0], " | ",ns[1], " | ",ns[2], " | ",ns[3], " | ",ns[4], " | ",ns[5], " | ",
			ns[6], " | ",ns[7], " | ",ns[8], " | ",ns[9], " | ",ns[10], " | ",ns[11], " | ",
			ns[12], " | ",ns[13], " | ",ns[14], " | ",ns[15], " \n")

		}
	}
	funcao cadeia hex(inteiro n){
		retorne Tipos.inteiro_para_cadeia(n, 16)
	}
	funcao cadeia hex2(inteiro n){
		retorne Texto.extrair_subtexto(Tipos.inteiro_para_cadeia(n, 16), 6, 8)
	}


	funcao inicio()
	{
		iniciar_graficos()
		carregar_fonte()

		cadeia caminho
		escreva("caminho da rom para abrir:")
		leia(caminho)
		
		abrir_rom(caminho)
		loop()
	}
	funcao iniciar_graficos(){
		Graficos.iniciar_modo_grafico(verdadeiro)
		Graficos.definir_dimensoes_janela(64*10, 32*10)
		Graficos.definir_titulo_janela("interpretador chip8 - portugol - by flaf")
	}


	funcao loop()
	{
	     inteiro tempo_inicial = Util.tempo_decorrido()
	     real intervalo = 1000 / hz  
	
		enquanto (verdadeiro)
		{
			controle()
			para(inteiro i = 0; i < instrucoes_por_frame; i++){
				ler()
				decodificar()
				executar()
			}
			renderizar()
			
			inteiro tempo_atual = Util.tempo_decorrido()
			inteiro tempo_passado = tempo_atual - tempo_inicial
			
			se (tempo_passado < intervalo)
			{
			 Util.aguarde(intervalo - tempo_passado)
			}
			
			tempo_inicial = Util.tempo_decorrido()
		}
	}
	funcao ler(){
		inteiro byte_maior = memoria[pc]
		inteiro byte_menor = memoria[pc+1]
		opcode = (byte_maior << 8) | byte_menor
		//escreva("> ", hex2(byte_maior), hex2(byte_menor),"\n")
	}

	
	funcao decodificar(){
		nnn = opcode & 0x0FFF
		nn = opcode & 0x00FF
		n = opcode & 0x000F
		x = (opcode & 0x0F00) >> 8
		y = (opcode & 0x00F0) >> 4
	}
	
	funcao executar() {
		se(dt > 0){
			dt--
		}
		se(st > 0){
			st--
		}
    escolha (opcode & 0xF000) {
        caso 0x0000:
            escolha (opcode & 0x00FF) {
                caso 0x00E0:
                    x00E0()
                    pare
                caso 0x00EE:
                	x00EE()
                	pare
            }
            pare
        caso 0x1000:
            x1NNN()
            pare
        caso 0x2000:
            x2NNN()
            pare
        caso 0x3000:
            x3XNN()
            pare
        caso 0x4000:
            x4XNN()
            pare
        caso 0x5000:
            x5XY0()
            pare
        caso 0x6000:
            x6XNN()
            pare
        caso 0x7000:
            x7XNN()
            pare
        caso 0x8000:
            escolha (opcode & 0x000F) {
                caso 0x0000:
                    x8XY0()
                    pare
                caso 0x0001:
                    x8XY1()
                    pare
                caso 0x0002:
                    x8XY2()
                    pare
                caso 0x0003:
                    x8XY3()
                    pare
                caso 0x0004:
                    x8XY4()
                    pare
                caso 0x0005:
                    x8XY5()
                    pare
                caso 0x0006:
                    x8XY6()
                    pare
                caso 0x0007:
                    x8XY7()
                    pare
                caso 0x000E:
                    x8XYE()
                    pare
            }
            pare
        caso 0x9000:
            x9XY0()
            pare
        caso 0xA000:
            xANNN()
            pare
        caso 0xB000:
            xBNNN()
            pare
        caso 0xC000:
            xCXNN()
            pare
        caso 0xD000:
            xDXYN()
            pare
        caso 0xE000:
            escolha (opcode & 0x00FF) {
                caso 0x009E:
                    xEX9E()
                    pare
                caso 0x00A1:
                    xEXA1()
                    pare
            }
            pare
        caso 0xF000:
            escolha (opcode & 0x00FF) {
                caso 0x0007:
                    xFX07()
                    pare
                caso 0x000A:
                    xFX0A()
                    pare
                caso 0x0015:
                    xFX15()
                    pare
                caso 0x0018:
                    xFX18()
                    pare
                caso 0x001E:
                    xFX1E()
                    pare
                caso 0x0029:
                    xFX29()
                    pare
                caso 0x0033:
                    xFX33()
                    pare
                caso 0x0055:
                    xFX55()
                    pare
                caso 0x0065:
                    xFX65()
                    pare
            }
            pare
    }
}

	funcao renderizar(){
		
		
		para(inteiro x = 0; x < 64; x++){
			para(inteiro y = 0; y < 32; y++){
				se(tela[x][y]){
					Graficos.definir_cor(0xf5b727)
				}senao{
					Graficos.definir_cor(0x19272e)
				}

				Graficos.desenhar_retangulo(x * 10, y * 10, 10, 10, falso, verdadeiro)
			}
		}

		Graficos.renderizar()

		
	}

	funcao controle(){
		para(inteiro i = 0; i <= 0xf; i++){
			teclado[i] = falso
		}

		evento_tecla = falso
		
		se(Teclado.tecla_pressionada(Teclado.TECLA_1)){
			teclado[0x1] = verdadeiro
			tecla_pressionada = 0x1
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_2)){
			teclado[0x2] = verdadeiro
			tecla_pressionada = 0x2
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_3)){
			teclado[0x3] = verdadeiro
			tecla_pressionada = 0x3
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_4)){
			teclado[0xC] = verdadeiro
			tecla_pressionada = 0xC
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_Q)){
			teclado[0x4] = verdadeiro
			tecla_pressionada = 0x4
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_W)){
			teclado[0x5] = verdadeiro
			tecla_pressionada = 0x5
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_E)){
			teclado[0x6] = verdadeiro
			tecla_pressionada = 0x6
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_R)){
			teclado[0xD] = verdadeiro
			tecla_pressionada = 0xD
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_A)){
			teclado[0x7] = verdadeiro
			tecla_pressionada = 0x7
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_S)){
			teclado[0x8] = verdadeiro
			tecla_pressionada = 0x8
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_D)){
			teclado[0x9] = verdadeiro
			tecla_pressionada = 0x9
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_F)){
			teclado[0xE] = verdadeiro
			tecla_pressionada = 0xE
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_Z)){
			teclado[0xA] = verdadeiro
			tecla_pressionada = 0xA
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_X)){
			teclado[0x0] = verdadeiro
			tecla_pressionada = 0x0
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_C)){
			teclado[0xB] = verdadeiro
			tecla_pressionada = 0xB
		}senao se(Teclado.tecla_pressionada(Teclado.TECLA_V)){
			teclado[0xF] = verdadeiro
			tecla_pressionada = 0xF
		}

		se(Teclado.alguma_tecla_pressionada()){
			evento_tecla = verdadeiro
		}
	}

	// intruções

	funcao x00E0(){ // limpar tela
		para(inteiro x = 0; x < 64; x++){
			para(inteiro y = 0; y < 32; y++){
				tela[x][y] = falso
			}
		}
		pc += 2
	}
	funcao x00EE(){
		pc = stack[sp]
		sp--
		pc += 2
	}
	funcao x1NNN(){
		pc = nnn
	}
	funcao x2NNN(){
		sp++
		stack[sp] = pc 
		pc = nnn
	}
	funcao x3XNN(){
		se(v[x] == nn){
			pc += 2
		}
		pc += 2
	}
	funcao x4XNN(){
		se(nao (v[x] == nn)){
			pc += 2
		}
		pc += 2
	}
	funcao x5XY0(){
		se(v[x] == v[y]){
			pc += 2
		}
		pc += 2
	}
	funcao x6XNN() // definir vx
	{
		v[x] = nn
		pc += 2
	}
	funcao x7XNN(){ // adicionar vx
		v[x] = (v[x] + nn) & 0xff
		pc += 2
	}
	funcao x8XY0(){
		v[x] = v[y]
		pc += 2
	}
	funcao x8XY1(){
		v[x] = v[x] | v[y]
		v[0xf] = 0
		pc += 2
	}
	funcao x8XY2(){
		v[x] = v[x] & v[y]
		v[0xf] = 0
		pc += 2
	}
	funcao x8XY3(){
		v[x] = v[x] ^ v[y]
		v[0xf] = 0
		pc += 2
	}
	funcao x8XY4(){
		inteiro c
		se(v[x] + v[y] > 0xff){
			c = 1
		}senao{
			c = 0
		}

		v[x] = (v[x] + v[y]) & 0xff 
		v[0xf] = c
		
		pc += 2
	}
	funcao x8XY5(){
		inteiro c
		se(v[x] >= v[y]){
			c = 1
		}senao{
			c = 0
		}

		v[x] = (v[x] - v[y]) & 0xff 
		v[0xf] = c
		
		pc += 2
	}
	funcao x8XY6(){
		v[x] = v[y]
		inteiro bit_trocado = v[x] & 0x01
		v[x] = (v[x] >> 1) & 0xff
		v[0xf] = bit_trocado

		pc += 2
	}
	funcao x8XY7(){
		inteiro c
		se(v[y] >= v[x]){
			c = 1
		}senao{
			c = 0
		}

		v[x] = (v[y] - v[x]) & 0xff 
		v[0xf] = c
		
		pc += 2
	}
	funcao x8XYE(){
		v[x] = v[y]
		inteiro bit_trocado = v[x] >> 7
		v[x] = (v[x] << 1) & 0xff
		v[0xf] = bit_trocado

		pc += 2
	}
	funcao x9XY0(){
		se(nao(v[x] == v[y])){
			pc += 2
		}
		
		pc += 2
	}
	funcao xANNN() // definir i
	{
		i = nnn
		
		pc += 2
	}
	funcao xBNNN(){
		pc = nnn + v[0]
	}
	funcao xCXNN(){
		v[x] = sorteia(0, 255) & nn

		pc += 2
	}

	funcao xDXYN() // desenhar na tela
	{
		inteiro x = v[(opcode & 0x0F00) >> 8]
		inteiro y = v[(opcode & 0x00F0) >> 4]
		inteiro altura = opcode & 0x000F

		v[0xf] = 0
		
		para(inteiro yline = 0; yline < altura; yline++){
			inteiro pixel = memoria[i + yline]

			para(inteiro xline = 0; xline < 8; xline++){
				se(nao ((pixel & (0x80 >> xline)) == 0)){
					inteiro xi = (x + xline) % 64
					inteiro yi = (y + yline) % 32

					se(tela[xi][yi]){
						v[0xF] = 1
					}

					
					tela[xi][yi] = nao tela[xi][yi]
				}
			}
		}
		pc += 2
	}
	funcao xEX9E(){
		se(teclado[v[x] & 0xf]){
			pc += 2
		}
		pc += 2
	}
	funcao xEXA1(){
		se(nao teclado[v[x] & 0xf]){
			pc += 2
		}
		pc += 2
	}
	funcao xFX07(){
		v[x] = dt

		pc += 2
	}
	funcao xFX0A(){
		pc -= 2
		se(evento_tecla){
			v[x] = tecla_pressionada & 0xf
			pc += 2
		}
		pc += 2
		
	}
	funcao xFX15(){
		dt = v[x]

		pc += 2
	}
	funcao xFX18(){
		st = v[x]

		pc += 2
	}
	funcao xFX1E(){
		i += v[x] 

		pc += 2
	}
	funcao xFX29(){
		i = ((v[x] & 0xF) * 5) & 0xffff

		pc += 2
	}
	funcao xFX33(){

		inteiro centenas = (v[x] / 100)
		inteiro dezenas = ((v[x] / 10) % 10)
		inteiro unidades = (v[x] % 10)
		
		memoria[i] = centenas
		memoria[(i + 1) & 0xFFF] = dezenas
		memoria[(i + 2) & 0xFFF] = unidades

		pc += 2
	}
	funcao xFX55(){
		para(inteiro j = 0; j <= x; j++){
			memoria[i + j] = v[j]
		}
		i += x + 1

		pc += 2
	}
	funcao xFX65(){
		para(inteiro j = 0; j <= x; j++){
			v[j] = memoria[(j + i) & 0xFFF]
		}
		i += x + 1

		pc += 2
	}
}
