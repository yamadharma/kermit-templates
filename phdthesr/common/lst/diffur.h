/*
    Name: Header file for SDE computing
    Author: Andrew "Atcher" Tchernoivanov
	    tchernoivanov@gmail.com
    Copyright: Raccoon Programming Division
*/

# include <stdio.h>
# include <math.h>
# include <gsl/gsl_errno.h>
# include <gsl/gsl_matrix.h>
# include <gsl/gsl_odeiv.h>

# define N 1 // Количество узлов
# define Q_MAX 60 // Максимальное пороговое значение пакетов для алгоритма RED
# define Q_MIN 20 // Минимальное пороговое значение пакетов для алгоритма RED
# define W_MAX 32 // Максимальный размер TCP-окна
# define R 100 // Размер буфера
# define Tp 0.01 // Время прохождения пакета от источника до узла
# define wq 0.0007 // Вес очереди
# define delta 0.01 // 
# define C_SMALL 1600 // Количество обслужеваемых за 1 секунду пакетов

double Q_TR_L;
double Q_TR_R;
double Q_TR;
double ALPHA;
double BETA = 0.9;
double BETA_powared = 5; // Compress factor
double P_MAX = 0.1;  // Максимальная вероятность сброса
int K = 3; // Possible values are - 2,3,4

// Описываем нашу индикаторную функцию
double tau (double x)
{
 if (x > 0.0 )
  return 1.0;
 else
  return 0.0;
}

// Описываем функцию T
double T (double x)
{
 return (Tp+x/(double)C_SMALL);
}

// Описываем функцию C
double C (double x)
{
 if (C_SMALL < x)
  return (double)C_SMALL;
 else
  return x;
}

// Задаем функцию вычисления вероятности сброса
double p_RED (double x) // RED
{
  double p1,p2;

 if ((0.0 <= x) && (x < (double)Q_MIN))
  return 0;
 else if (x > (double)Q_MAX)
  return 1;
 else 
  {
   p1 = (double)(x -(double)Q_MIN);
   p2 = (double)((double)Q_MAX - (double)Q_MIN);
   return (double)((p1/p2)*P_MAX);
  }
}

double p_ARED (double x) // ARED
{
  double p, p1, p2;

// Computing P_MAX
  ALPHA = fmin(0.01, P_MAX/4);
  
  if ((x > Q_TR) && (P_MAX <= 0.5))
    p = P_MAX+ALPHA;
  else if ((x <= Q_TR) && (P_MAX >= 0.01))
    p = P_MAX*BETA;
  
  if (p<0.01) P_MAX=0.01;
  if (p>0.5) P_MAX=0.5;
  P_MAX = p;
  
// Computing p
  if ((0.0 <= x) && (x < (double)Q_MIN))
    return 0;
  else if (x > (double)Q_MAX)
    return 1;
  else 
   {
     p1 = (double)(x -(double)Q_MIN);
     p2 = (double)((double)Q_MAX - (double)Q_MIN);
     return (double)((p1/p2)*P_MAX);
   }
}

double p_RARED (double x) // RARED
{
    int a,b;
    double c,d,p,p1,p2;
// Computing P_MAX
    if ((x > Q_TR) && (P_MAX <= 0.5))
    {
	a = Q_TR - x;
	c = (double) a / (double) Q_TR;
	d = c*P_MAX;
	ALPHA = 0.25 * d;
	p = P_MAX + ALPHA;
    }
    else if ((x <= (double) Q_TR) && (P_MAX >= 0.01))
    {
	a = Q_TR - x;
	b = (int)Q_TR - (int)Q_MIN;
	c = (double)a / (double)b;
	d = 0.17*c;
	BETA = 1 - d;
	p = P_MAX * BETA;
    }
    if (p<0.01) P_MAX = 0.01;
    if (p>0.5) P_MAX = 0.5;
    P_MAX = p;
// Computing P
    if ((0.0 <= x) && (x < (double)Q_MIN))
       return 0;
    else if (x > (double)Q_MAX)
       return 1;
    else 
     {
     p1 = (double)(x -(double)Q_MIN);
     p2 = (double)((double)Q_MAX - (double)Q_MIN);
     return (double)((p1/p2)*P_MAX);
     }
}

double p_POWARED (double x) //POWARED
{
    double p, sigma, dev, p1,p2,p3,p4,p11,p21;
    //Computing p_max
    dev = x - Q_TR;
    if (dev < 0)
    {
	p1 = (double)dev / (double)Q_TR;
	p3 = p1 / (double) BETA;
	p4 = pow(p3,K);
	sigma = fabs(p4);
    	p = P_MAX-sigma;
    	if ( p < 0) p = 0;
	P_MAX = p;
    }
    else if (dev > 0)
    {
	p11 = (double) R - (double)Q_TR;
	p1 = dev / p11;
	p3 = p1 / (double) BETA;
	p4 = pow(p3,K);
	sigma = fabs(p4);
	p = P_MAX+sigma;
	if ( p > 1 ) p = 1;
	P_MAX = p;
    }
    else if (dev == 0) p = P_MAX;
//Computing p
    if ((0.0 <= x) && (x < (double)Q_MIN))
       return 0;
    else if (x > (double)Q_MAX)
       return 1;
    else 
     {
     p1 = (double)(x -(double)Q_MIN);
     p2 = (double)((double)Q_MAX - (double)Q_MIN);
     return (double)((p1/p2)*P_MAX);
     }
}

double W_Reno_RED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])*(1/T(y[1])))
  +(-((y[0])/2)*(y[0]/T(y[1])))*p_RED(y[2]));
}

double W_Reno_ARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])*(1/T(y[1])))
  +(-((y[0])/2)*(y[0]/T(y[1])))*p_ARED(y[2]));
}

double W_Reno_RARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])*(1/T(y[1])))
  +(-((y[0])/2)*(y[0]/T(y[1])))*p_RARED(y[2]));
}

double W_Reno_POWARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])*(1/T(y[1])))
  +(-((y[0])/2)*(y[0]/T(y[1])))*p_POWARED(y[2]));
}

double W_FReno_RED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])/T(y[1]))
  + (-(((y[0]))*((y[0]))/2)*(1-p_RED(y[2]))
  *p_RED(y[2]) / T(y[1]))+ ((y[0])*(1-(y[0]))*(p_RED(y[2])
  *p_RED(y[2])) / T(y[1])));
}

double W_FReno_ARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])/T(y[1]))
  + (-(((y[0]))*((y[0]))/2)*(1-p_ARED(y[2]))
 *p_ARED(y[2]) / T(y[1]))+ ((y[0])*(1-(y[0]))
 *(p_ARED(y[2])*p_ARED(y[2])) / T(y[1])));
}

double W_FReno_RARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])/T(y[1])) 
  + (-(((y[0]))*((y[0]))/2)*(1-p_RARED(y[2]))
  *p_RARED(y[2]) / T(y[1]))+((y[0])*(1-(y[0]))
  *(p_RARED(y[2])*p_RARED(y[2])) / T(y[1])));
}

double W_FReno_POWARED (double y[])
{
  return (double)((tau((double)W_MAX-y[0])/T(y[1]))
  + (-(((y[0]))*((y[0]))/2)*(1-p_POWARED(y[2]))
  *p_POWARED(y[2]) / T(y[1]))+((y[0])*(1-(y[0]))
  *(p_POWARED(y[2])*p_POWARED(y[2])) / T(y[1])));
}

double Q_RED (double y[])
{
  return (double)(-C(y[1])+(tau((double)R-y[1]))
  *(y[0]/T(y[1]))*(1-p_RED(y[2]))*N);
}

double Q_ARED (double y[])
{
  return (double)(-C(y[1])+(tau((double)R-y[1]))
  *(y[0]/T(y[1]))*(1-p_ARED(y[2]))*N);
}

double Q_RARED (double y[])
{
  return (double)(-C(y[1])+(tau((double)R-y[1]))
  *(y[0]/T(y[1]))*(1-p_RARED(y[2]))*N);
}

double Q_POWARED (double y[])
{
  return (double)(-C(y[1])+(tau((double)R-y[1]))
  *(y[0]/T(y[1]))*(1-p_POWARED(y[2]))*N);
}

double Qe (double y[])
{
  return (double)(((log(1-wq)/delta)*y[2])
  -((log(1-wq)/delta)*y[1]));
}

int func (double t, const double y[], double f[], void *params)
{
  f[0]=W_FReno_ARED(y);
  f[1]=Q_ARED(y); 
  f[2]=Qe(y);

 return GSL_SUCCESS;
}
