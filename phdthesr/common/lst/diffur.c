/*
    Name: Main file for SDE computing
    Author: Andrew "Atcher" Tchernoivanov
	    tchernovanov@gmail.com
    Copyright: Raccoon Programming Division
*/

# include <stdio.h>
# include <math.h>
# include <gsl/gsl_errno.h>
# include <gsl/gsl_matrix.h>
# include <gsl/gsl_odeiv.h>
# include "diffur.h"

int main ()
{
  // Задаем границы нашего временного интервала
 double t0 = 0.0, t1 = 200.0;
 // Задаем точку начала отсчета
 double t = t0;
 // и определяем желаемый шаг, с которым у нас будет вычисляться значения
 double h = 1e-3;

// Размерность системы
 int dim_ode = 3;

 // Вектор-столбец, задающий начальные условия
 double y[3] = {1.0, 0.0, 0.0};

 // Определяем метод, который будет использоваться для решения данной системы уравнений
 const gsl_odeiv_step_type *P = gsl_odeiv_step_rk4;

 // Программная: возвращает указатель на начало массива координат
 // для заданного шага и размерности системы
 gsl_odeiv_step *s = gsl_odeiv_step_alloc (P,dim_ode);
 // Программная: создание переменной, в которой будет храниться
 // накопленная при вычислениях ошибка
 gsl_odeiv_control *c = gsl_odeiv_control_y_new (h, t0);
 // Программная: возвращает указатель на массив для 
 // заданной размерности системы
 gsl_odeiv_evolve *e = gsl_odeiv_evolve_alloc (dim_ode);

 // Определяем нашу общую систему уравнений, передавая
 // func - указатель на нашу систему диффуров
 // NULL - здесь указывается якобиан, если он есть
 // dim_ode - размерность нашей системы уравнений
 // NULL - дополнительные параметры, если имеются 
 gsl_odeiv_system sys = {func, NULL, dim_ode, NULL};

 ALPHA = fmin (0.01, P_MAX/4);
 Q_TR_L = (Q_MIN + (0.4*(Q_MAX-Q_MIN)));
 Q_TR_R = (Q_MIN + (0.6*(Q_MAX-Q_MIN)));
 Q_TR = (Q_TR_L + Q_TR_R) / 2;
 
 // Запускаем наш таймер
 while (t < t1)
 {
   // Считаем значения нашей системы в заданный момент 
   // времени при заданных условиях
  int status = gsl_odeiv_evolve_apply (e,c,s,&sys,&t,t1,&h,y);
 
  
  if (status != GSL_SUCCESS) // В случае ошибки
    break;                   // прерываем выполнение
  // Выдаем необходимые нам параметры
  printf ("%f %f %f %f\n", t, y[0], y[1], y[2]);
 }
 
 // Освобождаем память
 gsl_odeiv_evolve_free (e);
 gsl_odeiv_control_free (c);
 gsl_odeiv_step_free (s);
 
 exit (0);
}
