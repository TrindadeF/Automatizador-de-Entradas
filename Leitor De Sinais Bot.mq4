//+------------------------------------------------------------------+
//|                                              Leitor de Sinal.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_color2 clrBlue
#property indicator_width1 2
#property indicator_width2 2
#define Painel "MANUAL"
#define NOME_BOTAO "CALL"
#define NOME_BOTAO1 "PUT"


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

enum entradaSinal {
   Atual = 0,  
   Proxima = 1
};

//painel inicial
input string Nome_do_Sinal = "";
input string s1 = "=========== INDICADOR 1==========="; // ==Configuração Do Indicador de Sinal==
extern bool  Usar_Indicador_1 = True;
input string NomeIndicador_1 = ""; // Nome do Arquivo Indicador de Sinal
input int CallBufferIndicador_1 = 0;      // Buffer de Sinal -> Compra ("Call") 
input int PutBufferIndicador_1 = 1;       // Buffer de Sinal -> Venda ("Put")

input string s2= "=========== INDICADOR 2==========="; // ==Configuração Do Indicador de Sinal==
extern bool  Usar_Indicador_2 = False;
input string NomeIndicador_2 = ""; // Nome do Arquivo Indicador de SinalBot
input int CallBufferIndicador_2 = 0;      // Buffer de Sinal -> Compra ("Call") 
input int PutBufferIndicador_2 = 1;       // Buffer de Sinal -> Venda ("Put")

input string s3= "=========== INDICADOR 3==========="; // ==Configuração Do Indicador de Sinal==
extern bool  Usar_Indicador_3 = False;
input string NomeIndicador_3 = ""; // Nome do Arquivo Indicador de Sinal
input int CallBufferIndicador_3 = 0;      // Buffer de Sinal -> Compra ("Call") 
input int PutBufferIndicador_3 = 1;       // Buffer de Sinal -> Venda ("Put")

input string s4= "=========== INDICADOR 4==========="; // ==Configuração Do Indicador de Sinal==
extern bool  Usar_Indicador_4 = False;
input string NomeIndicador_4 = ""; // Nome do Arquivo Indicador de Sinal
input int CallBufferIndicador_4 = 0;      // Buffer de Sinal -> Compra ("Call") 
input int PutBufferIndicador_4 = 1;       // Buffer de Sinal -> Venda ("Put")

input string s5= "=========== INDICADOR 5==========="; // ==Configuração Do Indicador de Sinal==
extern bool  Usar_Indicador_5 = False;
input string NomeIndicador_5 = ""; // Nome do Arquivo Indicador de Sinal
input int CallBufferIndicador_5 = 0;      // Buffer de Sinal -> Compra ("Call") 
input int PutBufferIndicador_5 = 1;       // Buffer de Sinal -> Venda ("Put")

input string sss = "===========CONFIGURAÇÕES======="; // ==Configuração Do Local do Sinal==
input int Quantos_Indicadores = 1;// Quantidade de indicadores.
input entradaSinal EntradaSinal = Proxima; // Entrada na Vela
input int TempoExpiracao = 0; // Tempo de Expiração da Vela
extern bool Entrada_Manual = False;
extern bool Alerta_de_Entrada = False;



string ssss = "=========== Local======="; // ==Configuração Do Local do Sinal==
string LocalArqRetorno= ""; // Local Onde Salvar o Arquivo de Sinal

//variaveis
datetime tempoEnviado;
string terminal_data_path;
string nomearquivo;
string data_patch;
int fileHandle;
int tempo_expiracao;
string Indicador_1;
string Indicador_2;
string Indicador_3;
string Indicador_4;
string Indicador_5;

double ArrowUPbuff[];
double ArrowDNbuff[];
int Xp = 100;
int Yp = 32;

int OnInit()
  {
   Comment("Leitor De Sinal OFF !!! ");
//--- indicator buffers mapping
   IndicatorBuffers(2);
   SetIndexStyle (0,DRAW_ARROW);
   SetIndexArrow (0,233);
   SetIndexBuffer(0,ArrowUPbuff);
   SetIndexStyle (1,DRAW_ARROW);
   SetIndexArrow (1,234);
   SetIndexBuffer(1,ArrowDNbuff);

   EventSetTimer(1); 
   tempoEnviado = TimeCurrent();
   terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\";
   MqlDateTime time;
   datetime tempo = TimeToStruct(TimeLocal(),time);
   string hoje = StringFormat("%d%02d%02d",time.year,time.mon,time.day);
   nomearquivo = "Sinal.csv";
   data_patch = LocalArqRetorno;
   tempo_expiracao = TempoExpiracao;
   if(tempo_expiracao == 0){
      tempo_expiracao = Period();
   }   
    
   ObjectCreate(0,Painel, OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,Painel,OBJPROP_CORNER,3);
   ObjectSetInteger(0,Painel,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,Painel,OBJPROP_YSIZE,32);
   ObjectSetInteger(0,Painel,OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,Painel,OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,Painel,OBJPROP_BGCOLOR,0);
   ObjectSetString(0,Painel,OBJPROP_TEXT,"Entrada Manual");;
   ObjectSetInteger(0,Painel,OBJPROP_SELECTED,True);

   ObjectCreate(0,NOME_BOTAO, OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_CORNER,3);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_YSIZE,35);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_BGCOLOR,clrGreen);
   ObjectSetString(0,NOME_BOTAO,OBJPROP_TEXT,"CALL");;
   ObjectSetInteger(0,NOME_BOTAO,OBJPROP_SELECTED,True);
   
   ObjectCreate(0,NOME_BOTAO1, OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_CORNER,3);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_YSIZE,35);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_YDISTANCE,35);
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_BGCOLOR,clrRed);
   ObjectSetString(0,NOME_BOTAO1,OBJPROP_TEXT,"PUT");;
   ObjectSetInteger(0,NOME_BOTAO1,OBJPROP_SELECTED,True);
   

      if(data_patch == ""){
      data_patch = terminal_data_path;
   }
      
   if(FileIsExist(nomearquivo,0)){
      Print("Local do Arquivo: "+data_patch+nomearquivo);
      fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
      string data = "tempo,ativo,acao,expiracao,estrategia";
      FileWrite(fileHandle,data);
      FileClose(fileHandle);
      
   }
   else{
      Print("Criando Arquivo de Leitor de Sinal");
      Print("Local do Arquivo: "+data_patch+nomearquivo);
      fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
      string data = "tempo,ativo,acao,expiracao,estrategia";
      FileWrite(fileHandle,data);
      FileClose(fileHandle);
      
   }      
//---
   return(INIT_SUCCEEDED);
  }
 
 void OnDeinit(const int reason)
{
   EventKillTimer();
      
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   double call_1 = 0, put_1 = 0, call_2 = 0, put_2 = 0, call_3 = 0, put_3 = 0, call_4 = 0, put_4 = 0, call_5 = 0, put_5 = 0;
   ResetLastError();
   
     if (NomeIndicador_1 != "" && Usar_Indicador_1 == True) {
        call_1 = iCustom(NULL, 0, NomeIndicador_1, CallBufferIndicador_1,EntradaSinal);
        put_1 = iCustom(NULL, 0, NomeIndicador_1, PutBufferIndicador_1,EntradaSinal);
        Indicador_1 = NomeIndicador_1;
        
     }
     else {
        Print("ERRO!!! Verifique o Nome do Indicador 1!");
     }
   
        if (NomeIndicador_2 != "" && Usar_Indicador_2 == True) {
         call_2 = iCustom(NULL, 0, NomeIndicador_2, CallBufferIndicador_2,EntradaSinal);
         put_2 = iCustom(NULL, 0, NomeIndicador_2, PutBufferIndicador_2,EntradaSinal);
         Indicador_2 = NomeIndicador_2;
         }
         else {
           Print("ERRO!!! Verifique o Nome do Indicador 2!");
          }
      
        if (NomeIndicador_3 != "" && Usar_Indicador_3 == True ) {
         call_3 = iCustom(NULL, 0, NomeIndicador_3, CallBufferIndicador_3,EntradaSinal);
         put_3 = iCustom(NULL, 0, NomeIndicador_3, PutBufferIndicador_3,EntradaSinal);
         Indicador_3 = NomeIndicador_3;
         }
         else {
              Print("ERRO!!! Verifique o Nome do Indicador 3!");
             }
   
        if (NomeIndicador_4 != "" && Usar_Indicador_4 == True) {
           call_4 = iCustom(NULL, 0, NomeIndicador_4, CallBufferIndicador_4,EntradaSinal);
           put_4 = iCustom(NULL, 0, NomeIndicador_4, PutBufferIndicador_4,EntradaSinal);
           Indicador_4 = NomeIndicador_4;
           }
           else {
               Print("ERRO!!! Verifique o Nome do Indicador 4!");
              }
      
        if (NomeIndicador_5 != "" && Usar_Indicador_5 == True) {
           call_5 = iCustom(NULL, 0, NomeIndicador_5, CallBufferIndicador_5,EntradaSinal);
           put_5 = iCustom(NULL, 0, NomeIndicador_5, PutBufferIndicador_5,EntradaSinal);
           Indicador_5 = NomeIndicador_5;
           }
           else {
               Print("ERRO!!! Verifique o Nome do Indicador 5!");
              }
   
   int erro = GetLastError();
   if (erro == 4072) {
      Print("ERRO!!! Indicador Não Encontrado!");
      ResetLastError();
      }
   if(Quantos_Indicadores > 0 && Quantos_Indicadores < 6){Comment("Leitor De Sinal ON!!! Indicadores Ligados : "+Indicador_1+"  "+ Indicador_2+"  "+Indicador_3+"  "+Indicador_4+"  "+Indicador_5);}
   
   
   if (Quantos_Indicadores == 1 && Usar_Indicador_1 == True) {        
      if (sinal(call_1) && Time[0] > tempoEnviado) {
         Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL,"+Nome_do_Sinal); }
         ArrowUPbuff[0] = Low[0]-15*Point;       
      }
            
      if (sinal(put_1) && Time[0] > tempoEnviado) {
         Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0]; 
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT,"+Nome_do_Sinal); }
         ArrowDNbuff[0] = High[0]+15*Point; 
      }}
      
   if (Quantos_Indicadores == 2 && Usar_Indicador_1 == True && Usar_Indicador_2 == True) {        
      if (sinal(call_1) && sinal(call_2) && Time[0] > tempoEnviado) {
         Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL,"+Nome_do_Sinal); }
         ArrowUPbuff[0] = Low[0]-15*Point;       
      }
            
      if (sinal(put_1) && sinal(put_2) && Time[0] > tempoEnviado) {
         Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT,"+Nome_do_Sinal); }
         ArrowDNbuff[0] = High[0]+15*Point;  
      }}
      
   if (Quantos_Indicadores == 3 && Usar_Indicador_1 == True && Usar_Indicador_2 == True && Usar_Indicador_3 == True) {        
      if (sinal(call_1) && sinal(call_2) && sinal(call_3) && Time[0] > tempoEnviado) {
         Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0]; 
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL,"+Nome_do_Sinal); }
         ArrowUPbuff[0] = Low[0]-15*Point;      
      }
            
      if (sinal(put_1) && sinal(put_2) && sinal(put_3) && Time[0] > tempoEnviado) {
         Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT,"+Nome_do_Sinal); }
         ArrowDNbuff[0] = High[0]+15*Point;  
      }}
      
   if (Quantos_Indicadores == 4 && Usar_Indicador_1 == True && Usar_Indicador_2 == True && Usar_Indicador_3 == True && Usar_Indicador_4 == True) {        
      if (sinal(call_1) && sinal(call_2) && sinal(call_3) && sinal(call_4) && Time[0] > tempoEnviado) {
         Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL,"+Nome_do_Sinal); }
         ArrowUPbuff[0] = Low[0]-15*Point;       
      }
            
      if (sinal(put_1) && sinal(put_2) && sinal(put_3) && sinal(put_4) && Time[0] > tempoEnviado) {
         Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT,"+Nome_do_Sinal); }
         ArrowDNbuff[0] = High[0]+15*Point;  
      }}
      
   if (Quantos_Indicadores == 5 && Usar_Indicador_1 == True && Usar_Indicador_2 == True && Usar_Indicador_3 == True && Usar_Indicador_4 == True && Usar_Indicador_5 == True) {        
      if (sinal(call_1) && sinal(call_2) && sinal(call_3) && sinal(call_4) && sinal(call_5) && Time[0] > tempoEnviado) {
         Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL,"+Nome_do_Sinal); }
         ArrowUPbuff[0] = Low[0]-15*Point;       
      }
            
      if (sinal(put_1) && sinal(put_2) && sinal(put_3) && sinal(put_4) && sinal(put_5) && Time[0] > tempoEnviado) {
         Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END); 
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+","+Nome_do_Sinal;
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
         tempoEnviado = Time[0];
         if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT,"+Nome_do_Sinal); }
         ArrowDNbuff[0] = High[0]+15*Point; 
      }}
   
//--- return value of prev_calculated for next call
   return(rates_total);
   
}

bool sinal (double value) 
{
   if (value != 0 && value != EMPTY_VALUE)
      return true;
   else
      return false;
} 

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
    if(Entrada_Manual == True){

      if(sinal(id==CHARTEVENT_OBJECT_CLICK) && sinal(sparam == NOME_BOTAO)){
            
            Print(Symbol(), "," , tempo_expiracao , ",CALL," , Time[0]);
            fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
            FileSeek(fileHandle, 0, SEEK_END); 
            string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(tempo_expiracao)+",Entrada Manual";
            FileWrite(fileHandle,data);
            FileClose(fileHandle);
            tempoEnviado = Time[0];
            if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", CALL, Entrada Manual"); }
            ArrowUPbuff[0] = Low[0]-15*Point;
            
         }
         
            if(sinal(id==CHARTEVENT_OBJECT_CLICK) && sinal(sparam == NOME_BOTAO1)){
         
            Print(Symbol() , "," , tempo_expiracao ,",PUT," , Time[0]);
            fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
            FileSeek(fileHandle, 0, SEEK_END); 
            string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(tempo_expiracao)+",Entrada Manual";
            FileWrite(fileHandle,data);
            FileClose(fileHandle);
            tempoEnviado = Time[0];
            if( Alerta_de_Entrada == True ) { Alert(Symbol()," M"+IntegerToString(tempo_expiracao), ", PUT, Entrada Manual"); }
            ArrowDNbuff[0] = High[0]+15*Point; 
            
         }
      }
  }