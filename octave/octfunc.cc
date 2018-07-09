#include <octave/oct.h>
#include <string.h>

/* Octave interface for graphene program.
 *                               slazav, 2018 */

#if NARGIN == 5
double FUNC_(double *a1, double *a2, double *a3,
            double *a4, double *a5);
#endif
#if NARGIN == 6
double FUNC_(double *a1, double *a2, double *a3,
            double *a4, double *a5, double *a6);
#endif
#if NARGIN == 7
double FUNC_(double *a1, double *a2, double *a3,
            double *a4, double *a5, double *a6,
            double *a7);
#endif
#if NARGIN == 8
double FUNC_(double *a1, double *a2, double *a3,
            double *a4, double *a5, double *a6,
            double *a7, double *a8);
#endif
#endif

DEFUN_DLD(db_get_range, args, nargout, "get data from database") {

  if (nargout==0) {}
  /*check number of arguments */
  if (args.length() != NARGIN)
    error("wrong number of arguments, %d expected", NARGIN);

  if (args.length() > 8)
    error("functions with > 8 arguments are not supported in octfunc.c");


/* Functions */
#if NARGIN > 0
  /* Get input arguments, calculate maximal size */
  NDArray ina[NARGIN];
  double  *in[NARGIN];
  bool s[NARGIN];
  dim_vector dv0(1,1);
  int numel = 1;

  for (int i=0; i<NARGIN; i++){
    if (!args(i).is_numeric_type())
      error("numeric matrix or scalar expected in argument %d", i);

    ina[i] = args(i).array_value(); // array
    in[i] = ina[i].fortran_vec();   // pointer to its raw data
    s[i] = ina[i].numel()==1; // has 1 element?

    if (!s[i]) {
      if (numel!=1 && ina[i].ndims()!=dv0.ndims())
        error("wrong dimensions of argument %d", i);
      if (numel!=1 && ina[i].numel()!=numel)
        error("wrong number of elements in argument %d", i);
      dv0 = ina[i].dims();
      numel = ina[i].numel();
    }
  }

  /* allocate space for output data */
  NDArray out(dv0);
  double *o = out.fortran_vec();

  /* calculate values */
  for (int i=0; i<numel; i++){
    OCTAVE_QUIT; // octave can break here;
#if NARGIN == 1
    o[i] = FUNC_(in[0]+(s[0]?0:i));
  }
  return octave_value(out);
#endif
}
