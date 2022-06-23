from iqoptionapi.stable_api import IQ_Option
import csv, logging, time, json, configparser, sys, requests
from datetime import datetime, date, timedelta
from dateutil import tz
from pathlib import Path
from colorama import *
init(autoreset=True)

logging.disable(level=(logging.DEBUG))

def linha():
    print(Fore.GREEN + '------------------------------------------------------------------------------------------')

linha()
print(Fore.BLUE + '           ##### #### ### ## #AUTOMATIZADO DE INDICADOR MT4# ## ### #### #####')
print(Fore.BLUE + '           ##### #### ### ## #  SUPORTE: autobotmt4@gmail.com # ## ### ')      
print(Fore.BLUE + '           ##### #### ### ## #      VERSAO 1.0        # ## ### #### #####')
print(Fore.BLUE + '           ##### #### ### ## # MODIFICADO BY: @BotAut  # ## ### #### #####')
linha()

def configuracao():
	arquivo = configparser.RawConfigParser()
	arquivo.read('Login.txt')	
		
	return {'Email': arquivo.get('LOGIN', 'Email'),'Senha': arquivo.get('LOGIN', 'Senha'), 'LOCAL_PASTA_MQL4': arquivo.get('LOGIN', 'LOCAL_PASTA_MQL4'),'Fazer_Soros': arquivo.get('SOROS', 'Fazer_Soros'),'Ciclo_Soros': arquivo.get('SOROS', 'Ciclo_Soros'),'Fazer_Martingale': arquivo.get('MARTINGALE', 'Fazer_Martingale'),'Valor_maximo_do_loss_para_ter_o_Martingale': arquivo.get('MARTINGALE', 'Valor_maximo_do_loss_para_ter_o_Martingale'), 'Stop_Gain': arquivo.get('GERENCIAMENTO', 'Stop_Gain'), 'Stop_Loss': arquivo.get('GERENCIAMENTO', 'Stop_Loss')}

config = configuracao()


MQL_DATA_PATH = Path(config['LOCAL_PASTA_MQL4'])


print(Fore.GREEN + f"API IQ_OPTION Versão: {IQ_Option.__version__}")

#Opções de operações para soros, Entrada, Real ou Treinamento################
while True:
	try:
		MODE = int(input('\n--> Deseja operar na Conta:\n--> 1 - Treinamento\n--> 2 - Real\n--> '))
        
		if MODE > 0 and MODE < 3 : break
	except:
		print(Fore.RED + '\n--> Opção invalida')

while True:
	try:
		valor_entrada = float(input("\n--> Valor das Entrada: "))
        
		if valor_entrada >= 1 : break
	except:
		print(Fore.RED + '\n--> Opção invalida')

martingale = config['Fazer_Martingale'].lower()
valor_p_iniciar_gale = float(config['Valor_maximo_do_loss_para_ter_o_Martingale'])

if martingale == 'n':
        valor_p_iniciar_gale = 0

fazer_soros = config['Fazer_Soros'].lower()
soros = int(config['Ciclo_Soros'])
        
if fazer_soros =='n':
    soros = 0

#Opções de operações para soros, Entrada, Real ou treinamento################
 
DATE_TIME_FORMAT = '%Y-%m-%d %H:%M'

valor_entrada_b = valor_entrada


########Login####################
API = IQ_Option(config['Email'], config['Senha'])
API.connect()
Email_de_verificação = 'santos.bruno44@gmail.com'
Email_Averificar = config['Email'].lower()


Tempo_da_Licença = '2020-08-30'
ExpirationDate = datetime.strptime(Tempo_da_Licença,"%Y-%m-%d").date()
now = date.today()
dias_resta = ExpirationDate - now
dias_resta = str(dias_resta)[:-9]
if ExpirationDate == now : dias_resta = 0

while True:
    if ExpirationDate >= now:
        Licença = True
    else:
        Licença = False

    if Licença == True and Email_de_verificação == Email_Averificar:
        print(Fore.GREEN + '\n--> Licença OK!')
        print(Fore.GREEN + '--> Dias Restantes: {}'.format(dias_resta))
        account_type = 'PRACTICE' if MODE == 1 else 'REAL'
        break
    else:
        print(Fore.RED + '\n--> Licença Invalida!')
        print(Fore.RED + '--> O automatizador funcionará apenas em modo treinamento')
        account_type = 'PRACTICE'
        break
########Login####################

while True:
	if API.check_connect() == False:
		print(Fore.RED + '--> Erro ao se conectar')
		API.connect()
	else:
		print(Fore.GREEN + '\n--> Conectado com sucesso!!!')
		break

	time.sleep(2)
    
print('                                                                ')
    
def perfil():
	perfil = json.loads(json.dumps(API.get_profile_ansyc()))
	
	return perfil


#-----------------------------------INFORMAÇÕES ----------------------------------------

stop_loss = int(config['Stop_Gain'])
stop_gain = int(config['Stop_Loss']) 
gale = 'Sim' if martingale == 's' else 'Nao' 
sorosR = 'Sim' if fazer_soros == 's' else 'Nao'
conta = 'Treinamento' if account_type == 'PRACTICE' else 'Real'

API.change_balance(account_type)
account_balance = '${:,.2f}'.format(API.get_balance()) if API.get_currency() == 'USD' else 'R${:,.2f}'.format(API.get_balance())
print(Fore.GREEN + '--> Nome: {}'.format(perfil()['name']))
print(Fore.GREEN + '--> Tipo de conta: {}'.format(conta))
print(Fore.GREEN + '--> Valor da banca: {}'.format(account_balance))
print(Fore.GREEN +'--> Valor da Entrada: {}'.format(valor_entrada))
print(Fore.GREEN +'--> Deseja operar com martingale: {}'.format(gale))
print(Fore.GREEN +'--> Valor maximo do loss para ter o Martingale: {}'.format(valor_p_iniciar_gale))
print(Fore.GREEN +'--> Deseja operar com soros: {}'.format(sorosR))
print(Fore.GREEN +'--> Quantidade de ciclo de soros: {}'.format(soros))
print(Fore.GREEN +'--> Valor do stop gain: {}'.format(stop_gain))
print(Fore.RED +'--> Valor do stop loss: {}'.format(stop_loss))

while True:
    verifica = input('\n--> Estão corretos os dados acima? [s] Sim | [n] Não: ').lower()
    if verifica != 's' and verifica != 'n':
        print('--> Por favor, informe se os dados estão corretos...')
    elif verifica == 'n':
        Sair_Sys('-->Por favor, corrija os dados no arquivo Login...')
    else:
        break
        
print('                                                                ')
linha()
print(Fore.GREEN + '--> Verificando o Sinais no Indicador...')
linha()
print(Fore.RED + '--> Pressione Ctrl+C para sair.\n')

#-----------------------------------INFORMAÇÕES ----------------------------------------
    
def timestamp_converter(x, retorno = 1):
	hora = datetime.strptime(datetime.utcfromtimestamp(x).strftime('%Y-%m-%d %H:%M:%S'), '%Y-%m-%d %H:%M:%S')
	hora = hora.replace(tzinfo=tz.gettz('GMT'))
	
	return str(hora.astimezone(tz.gettz('America/Sao Paulo')))[:-6] if retorno == 1 else hora.astimezone(tz.gettz('America/Sao Paulo'))
########################Noticias########################################################

response = requests.get("https://botpro.com.br/calendario-economico/")
texto = response.content
objeto = json.loads(texto)

if response.status_code != 200 or objeto['success'] != True:
    print(Fore.RED + '--> Erro ao Conectado notícias')
else:
    print(Fore.GREEN + '--> Conectado as notícias com susseso\n')

def noticias(ativo, tempo_delay):
        
    # Pega a data atual
    data = datetime.now()
    tm = tz.gettz('America/Sao Paulo')
    data_atual = data.astimezone(tm)
    data_atual = data_atual.strftime('%Y-%m-%d')
    
    paridade = ativo # Aqui é paridade ao qual deseja comparar com a noticia
    minutos_lista = int(tempo_delay)# Aqui é o tempo que iria começar a operação
    
    
    # Varre todos o result do JSON
    for noticia in objeto['result']:

        # Separa a paridade em duas Ex: AUDUSD separa AUD e USD para comparar os dois
        paridade1 = paridade[0:3]
        paridade2 = paridade[3:6]

        # Pega a paridade, impacto e separa a data da hora da API
        moeda = noticia['economy']
        impacto = noticia['impact']
        atual = noticia['data']
        nome = noticia['name']
        data = atual.split(' ')[0]
        hora = atual.split(' ')[1]

        print(Fore.GREEN + f'{moeda} / {impacto} / {atual} / {nome}')
    
        # Verifica se a paridade existe da noticia e se está na data atual
        if moeda == paridade1 or moeda == paridade2 and data == data_atual:
            formato = '%H:%M:%S'
            dif = (datetime.strptime(hora, formato) - datetime.fromstrptime(minutos_lista, formato)).total_seconds()
            # Verifica a diferença entre a hora da noticia e a hora da operação
            minutesDiff = dif / 60
      
            # Verifica se a noticia irá acontencer 30 min antes ou depois da operação
            if minutesDiff >= -20 and minutesDiff <= 0 or minutesDiff <= 20 and minutesDiff >= 0:
                touros = 'TOUROS' if impacto > 1 else 'TOURO'
                print(Fore.GREEN + f'# NOTÍCIA COM IMPACTO DE {impacto} {touros} NA MOEDA {moeda} ÀS {hora}!')
                break

##################################stop################################################## 
lucro_total = 0 
def stop(lucro_total, gain, loss):
	if lucro_total <= float('-' + str(abs(loss))):
		print(Fore.RED +'>>>> Stop Loss batido! =( SIGA O GERENCIAMENTO! <<<<')
		sys.exit()
		
	if lucro_total >= float(abs(gain)):
		print(Fore.GREEN +'>>>> Stop Gain Batido! =) SIGA O GERENCIAMENTO! <<<<')
		sys.exit() 
#####################################payout##############################
def payout(ativo):
		a = API.get_all_profit()
		return (int(a[ativo]["turbo"] * 100) / 100)
############################################################################

niveis = 0
win_gale = 0 
WIN = 0
LOSS = 0

while True:

    date = datetime.now()
    log_file = MQL_DATA_PATH / 'Files' / f'{date.strftime("%Y%m%d")}_retorno.csv'
#######################Atualização#############################################################################################
    balance_atual = '${:,.2f}'.format(API.get_balance()) if API.get_currency() == 'USD' else 'R${:,.2f}'.format(API.get_balance())
    print(datetime.now().strftime(Fore.GREEN +'%d.%m.%Y %H:%M:%S'),Fore.GREEN +'| Wins:'+str(WIN),Fore.RED +'| Loss:'+str(LOSS),'| TOTAL OPERAÇÕES:' +str(WIN+LOSS),Fore.GREEN + '| Banca:{}'.format(balance_atual),Fore.GREEN + '| Stop G/L:' + str(round(lucro_total, 2)),end='\r')
#######################config#################################################################################################
    lucro_soros = 0
    
###############################################################################   
    with open(log_file) as csv_file:
    
        csv_reader = csv.reader(csv_file, delimiter=',')
        csv_reader.__next__()

        delay = round(time.time())-1
       
        for row in csv_reader:
             
            tempo_delay = row[0] 
            ativo = row[1]
            direcao = row[2]
            timeframe = row[3]
            
            if(delay <= int(tempo_delay)):
                
                noticias(ativo, tempo_delay)
                status,id = API.buy(valor_entrada,ativo,direcao,int(timeframe))
                print('-->>>>> ' + str(datetime.fromtimestamp(int(tempo_delay))) + ' <<<<<--  |', ' Expiração: M' + timeframe + '   | Moeda: ' + ativo + ' | Direção:' + direcao + ' | Entrada: ' + str(round(valor_entrada, 2)),
                '\n-->>>>> Resultado: ', end='')
                if status: 
                    lucro = API.check_win_v3(id)
                    perca = lucro if lucro > 0 else float('+' + str(abs(valor_entrada)))
                    if lucro > 0:
                        resultado = 'win'
                        WIN += 1
                        ('Win','+' ,round(lucro, 2))
                        print('Moeda: ' + ativo + ' |',Fore.GREEN +'      Win   ' , '   | ',Fore.GREEN +'Valor do Ganho:' +str(round(lucro, 2)))

                    else:
                        resultado = 'loss'
                        LOSS += 1
                        ('Loss','-' + str(valor_entrada))
                        print('Moeda: ' + ativo + ' |',Fore.RED +'      Loss   ' , '   | ',Fore.RED + 'Valor da Perca: ' + str(round(lucro, 2)))
                else:
                    break
                    
                    
                lucro_total += lucro    
                stop(lucro_total, stop_gain, stop_loss)
############################soros ###############################      
                if resultado == 'win':
                    if fazer_soros == 's':                
                        if niveis <= soros :
                            if win_gale == 0:
                                valor_entrada += lucro
                                niveis += 1
                                print(Fore.GREEN + f'\n--> Quantidade de soros executada - '+str(niveis)+' nivel')
                    if martingale == 's':
                        if win_gale == 1:
                            valor_entrada = valor_entrada_b
                            print(Fore.GREEN + f'--> Martingale efetuado com sucesso!\n')
                            win_gale = 0
                            break
                            
                    
                else: 
                    if resultado == 'loss':
                        if fazer_soros == 's':                    
                            if niveis <= soros :
                                niveis = 0
                                valor_entrada = valor_entrada_b
                        if martingale == 's':
                            if perca < valor_p_iniciar_gale:
                                print(Fore.RED + f'\n--> Proxima entrada com Martingale')
                                valor_entrada = perca * 2.2
                                win_gale = 1
                                break
                                
                            else:
                                valor_entrada = valor_entrada_b
                                print(Fore.RED + f'--> Stop Gale! Gerenciamento Sempre!', '\n')
                                win_gale = 0
                                break 
                        
                if niveis > soros:
                    valor_entrada = valor_entrada_b
                    print(Fore.GREEN + f'--> Ciclo de Soros finalizado')
                    niveis = 0
                    break                    
    time.sleep(0.002)                