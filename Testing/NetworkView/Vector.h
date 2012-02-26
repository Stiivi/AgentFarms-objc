/* 2003 Jun 7 */

#ifndef __Vector_h__included__
#define __Vector_h__included__

#include <math.h>

typedef struct 
{
    float x;
    float y;
} Vector;

/* Return v1 - v2 */
static inline Vector Vector_difference(Vector v1, Vector v2)
{
    Vector v = { v1.x - v2.x, v1.y - v2.y };
    return v;
}

/* Return v1 + v2 */
static inline Vector Vector_sum(Vector v1, Vector v2)
{
    Vector v = { v1.x + v2.x, v1.y + v2.y };
    return v;
}


static inline Vector Vector_multiply(Vector v1, double value)
{
    Vector v = { v1.x*value, v1.y*value};
    return v;
}

static inline double Vector_length(Vector target)
{
    return sqrt(target.x*target.x + target.y*target.y);
}

static inline double Vector_length_squared(Vector target)
{
    return target.x*target.x + target.y*target.y;
}

static inline double Vector_distance(Vector v1,Vector v2)
{
    Vector v = { v2.x - v1.x, v2.y - v1.y };
    return sqrt(v.x*v.x + v.y*v.y);
}

static inline double Vector_distance_squared(Vector v1,Vector v2)
{
    Vector v = { v2.x - v1.x, v2.y - v1.y };
    return v.x*v.x + v.y*v.y;
}


static inline Vector Vector_negate(Vector target)
{
    Vector v = { -target.x, -target.y };
    return v;
}
static inline Vector Vector_unit(Vector v1)
{
    Vector v;
    double len = Vector_length(v1);
    v.x = v1.x / len;
    v.y = v1.y / len;
    
    return v;
}
#endif
