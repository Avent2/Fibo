//+------------------------------------------------------------------+
//|                                                   fmcbr_v1.1.mq4 |
//|                                              Mohd Hasrizam Hasan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Mohd Hasrizam Hasan"
#property description "Untuk kegunaan bersama, Free destribution"
#property link      ""
#property version   "1.10"
#property strict
#property indicator_chart_window
#property indicator_buffers 6

extern color BLUE= clrAqua;
extern color RED = clrRed;
extern int inDepth=50;
extern int Limit=240;
extern string Fibo_Level="Klik false untuk tutup level";
extern bool Base=true;
extern bool Entry1 = true;
extern bool Entry2 = true;
extern bool Premature_Entry_1 = true;
extern bool Premature_Entry_2 = true;
extern bool Pullback = true;
extern bool BreakOut = true;
extern bool TP1=true;
extern bool Ext_TP1_1 = true;
extern bool Ext_TP1_2 = true;
extern bool Premature_TP_1 = true;
extern bool Premature_TP_2 = true;
extern bool TP2=true;
extern bool Ext_TP2_1 = true;
extern bool Ext_TP2_2 = true;
extern bool Compelete_Cycle=true;
extern bool Ext_Compelete_Cycle_1 = true;
extern bool Ext_Compelete_Cycle_2 = true;

//+----- Global variable --------
double cbHi[],cbLow[],hi[],low[],breakHi[],breakLow[];
int fiboCount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ObjectsDeleteAll(0,OBJ_FIBO);
   SetIndexBuffer(0,hi); SetIndexStyle(0,DRAW_ARROW,0,2,clrRed); SetIndexArrow(0,242);
   SetIndexBuffer(1,low);  SetIndexStyle(1,DRAW_ARROW,0,2,clrBlue); SetIndexArrow(1,241);
   SetIndexBuffer(2,cbHi);  SetIndexStyle(2,DRAW_ARROW,0,2,clrBlue); //SetIndexArrow(2,140);  
   SetIndexBuffer(3,cbLow);  SetIndexStyle(3,DRAW_ARROW,0,2,clrRed); //SetIndexArrow(3,140); 
   SetIndexBuffer(4,breakHi);  SetIndexStyle(4,DRAW_ARROW,0,1,clrBlue);// SetIndexArrow(4,140);  
   SetIndexBuffer(5,breakLow);  SetIndexStyle(5,DRAW_ARROW,0,1,clrRed);// SetIndexArrow(5,140); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| deinit                                                           |
//+------------------------------------------------------------------+

int deinit() 
  {
   ObjectsDeleteAll(0,OBJ_FIBO);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    limit=300;

   if(counted_bars<0) return(-1);

   if(counted_bars>0) counted_bars--;

//Limit=Bars-counted_bars; 
//---- 

   getHiLow();
   findCb();
   cBreak();

   return(0);
  }
//+--------------- end main ----------------------------+

//+--------------- find hi low -------------------
void getHiLow()
  {
   int prePos,curPos;

   curPos=prePos=0;
   for(int i=0;i<=Limit;i++)
     {
      double zz= iCustom(Symbol(),0,"ZigZag",inDepth,5,3,0,i);
      double zzhi=iCustom(Symbol(),0,"ZigZag",inDepth,5,3,1,i);
      double zzLow=iCustom(Symbol(),0,"ZigZag",inDepth,5,3,2,i);

      if(zzhi>0)
         hi[i]=zz;
      else
         hi[i]=0.0;

      if(zzLow>0)
         low[i]=zz;
      else
         low[i]=0.0;

     }
  }
//+----------- end function --------------------

//+------------ function find break --------------

void cBreak()
  {
   ObjectsDeleteAll(0,OBJ_FIBO);
   bool breakHiFound,breakLowFound;
   double cbhi,cblow;
   breakHiFound=breakLowFound=false;
   cbhi=cblow=0;
   int x,i,y;
   double highest,lowest;
   datetime T1,T2;
   for(x=0;x<=Limit;x++)
     {
      breakLow[x]=0.0;
      breakHi[x]=0.0;
      if(hi[x]>0 || low[x]>0)
        {
         for(i=x;i<=x+20;i++)
           {// cari cbhi/cbLow
            if(cbHi[i]>0)
              {
               cbhi=cbHi[i];
               break;
              }
            else cbhi=0;

            if(cbLow[i]>0)
              {
               cblow=cbLow[i];
               break;
              }
            else cblow=0;
           }
        }
      for(y=x;y>=0;y--)
        {// cari break;
         if(cbhi>0 || cblow>0)
           {
            if(iClose(Symbol(),0,y)>cbhi && cbhi>0 && low[x]>0)
              {
               breakHi[y]=iClose(Symbol(),0,y);
               cbhi=0;
               highest=breakHi[y];
               lowest=iLow(Symbol(),0,x);
               T1=iTime(Symbol(),0,x);
               T2=iTime(Symbol(),0,x+2);
               DrawFibo(T1,T2,highest,lowest,"up");
               break;
              }
            else breakHi[y]=0.0;

            if(iClose(Symbol(),0,y)<cblow && cblow>0 && hi[x]>0)
              {
               breakLow[y]=iClose(Symbol(),0,y);
               cblow=0;
               highest=breakLow[y];
               lowest=iHigh(Symbol(),0,x);
               T1=iTime(Symbol(),0,x);
               T2=iTime(Symbol(),0,x+2);
               DrawFibo(T1,T2,highest,lowest,"down");
               break;
              }
            else breakLow[y]=0.0;
           }
        }

     }
  }
//+---------------- end function ------------------

//+------------------ function find cb key -------------------------+
void findCb()
  {
   ArrayInitialize(cbHi,0.0);
   ArrayInitialize(cbLow,0.0);
   for(int i=0;i<=Limit;i++)
     {
      int PointShift=i;
      string ConfirmedPoint="Not Found";
      string PointShiftDirection="Not Found";

      if(hi[i]>0 || low[i]>0)
        {
         while(ConfirmedPoint!="Found")
           {
            double ZZ=iCustom(NULL,0,"ZigZag",inDepth,5,3,0,PointShift);
            if(iHigh(NULL,0,PointShift)==ZZ || iLow(NULL,0,PointShift)==ZZ)
              {
               ConfirmedPoint="Found";
               if(iHigh(NULL,0,PointShift)==ZZ)
                 {
                  PointShiftDirection="High";
                  break;
                 }
               if(iLow(NULL,0,PointShift)==ZZ)
                 {
                  PointShiftDirection="Low";
                  break;
                 }
              }
            PointShift++;
           }

         int PointShift2=PointShift;
         string ConfirmedPoint2="Not Found";

         while(ConfirmedPoint2!="Found")
           {
            double ZZ2=iCustom(NULL,0,"ZigZag",2,1,1,0,PointShift2);
            double priceOpen=iOpen(Symbol(),0,PointShift2);
            double priceClose=iClose(Symbol(),0,PointShift2);

            if(iHigh(NULL,0,PointShift2)==ZZ2 && PointShiftDirection=="Low")
              {
               ConfirmedPoint2="Found";
               //cb1
               if(iClose(Symbol(),0,PointShift2)<iOpen(Symbol(),0,PointShift2))
                  cbHi[PointShift2]=priceOpen;
               else
                  cbHi[PointShift2]=priceClose;

               // if dominent exist

               if(checkDominentHi(PointShift))
                 {
                  cbHi[PointShift2]=0.0;
                  //Print("Dominent found Pointshift2 clear at: "+PointShift2);

                 }
               //---------------- 
               break;

              }
            else cbHi[PointShift2]=0.0;
            if(iLow(NULL,0,PointShift2)==ZZ2 && PointShiftDirection=="High")
              {
               ConfirmedPoint2="Found";
               if(iClose(Symbol(),0,PointShift2)>iOpen(Symbol(),0,PointShift2))
                  cbLow[PointShift2]=priceOpen;
               else
                  cbLow[PointShift2]=priceClose;
               // break;

               // if dominent exist

               if(checkDominentLow(PointShift))
                 {
                  cbLow[PointShift2]=0.0;
                  //Print("Dominent found Pointshift2 clear at: "+PointShift2);

                 }
               //---------------- 
               break;
              }
            else cbLow[PointShift2]=0.0;
            PointShift2++;
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+----------- find low dominent --------------
bool checkDominentLow(int i)
  {
   bool flag=false;
   double openPrice,closePrice,openPrice2,closePrice2;
   openPrice=openPrice2=closePrice=closePrice2=0;

   openPrice=iOpen(Symbol(),0,i);
   closePrice=iClose(Symbol(),0,i);

   if(openPrice<closePrice && hi[i]>0)
     {//bull
      int inside=0;
      for(int x=i-1;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2<closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice<closePrice2 && closePrice>=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbLow[i]=openPrice;
            break;
           }
        }
     }
   if(openPrice>closePrice && hi[i]>0)
     {//bear
      int inside=0;
      openPrice = iOpen(Symbol(),0,i+1);
      closePrice= iClose(Symbol(),0,i+1);
      for(int x=i;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2<closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice<closePrice2 && closePrice>=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbLow[i]=openPrice;
            break;
           }

        }
     }


   return(flag);
  }
//+------------ end find low dominent -----------------

//+----------- find hi dominent --------------
bool checkDominentHi(int i)
  {
   bool flag=false;
   double openPrice,closePrice,openPrice2,closePrice2;
   openPrice=openPrice2=closePrice=closePrice2=0;

   openPrice=iOpen(Symbol(),0,i);
   closePrice=iClose(Symbol(),0,i);

   if(openPrice>closePrice && low[i]>0)
     {//bull
      int inside=0;
      for(int x=i-1;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2>closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice>closePrice2 && closePrice<=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbHi[i]=openPrice;
            break;
           }
        }
     }

   if(openPrice<closePrice && low[i]>0)
     {//bear
      int inside=0;
      openPrice = iOpen(Symbol(),0,i+1);
      closePrice= iClose(Symbol(),0,i+1);
      for(int x=i;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2>closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice>closePrice2 && closePrice<=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbHi[i]=openPrice;
            break;
           }

        }
     }


   return(flag);
  }
//+------------ end find hi dominent -----------------

//------------ function draw fibo --------
void DrawFibo(datetime T1,datetime T2,double highest,double lowest,string direction)
  {
   fiboCount++;
   string fiboobjname="Fibo"+IntegerToString(fiboCount);

   if(direction=="up") {
      ObjectCreate(fiboobjname,OBJ_FIBO,0,T1,highest,T2,lowest);
      ObjectSet(fiboobjname,OBJPROP_LEVELCOLOR,BLUE);
   } else {
      ObjectCreate(fiboobjname,OBJ_FIBO,0,T1,highest,T2,lowest);
      ObjectSet(fiboobjname,OBJPROP_LEVELCOLOR,RED);
   }

   ObjectSet(fiboobjname,OBJPROP_FIBOLEVELS,8);

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL, -0.13);
   ObjectSetFiboDescription(fiboobjname, 0, "-13.0 = Stop Loss   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+1, 0.0);
   ObjectSetFiboDescription(fiboobjname, 1, "0.0 = Base   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+2, 0.382);
   ObjectSetFiboDescription(fiboobjname, 2, "38.2 = Level Entry 3   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+3, 0.5);
   ObjectSetFiboDescription(fiboobjname, 3, "50.0 = Level Entry 2   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+4, 1.0);
   ObjectSetFiboDescription(fiboobjname, 4, "100.0 = Level Entry 1   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+5, 1.618);
   ObjectSetFiboDescription(fiboobjname, 5, "161.8 = Level TP 1   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+6, 2.618);
   ObjectSetFiboDescription(fiboobjname, 6, "261.8 = Level TP 2   %$");

   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+7, 4.236);
   ObjectSetFiboDescription(fiboobjname, 7, "423.6 = Level TP 3   %$");

   ObjectSet(fiboobjname,OBJPROP_RAY,false);
  }
//------------ end function --------------