#version 330

in vec3 N3;  // normal vector in camera coord
in vec3 L3;  // light vector in camera coord (fragment -> light)
in vec3 V3;  // view vector in camera coord (fragment -> camera)
in vec3 wV;  // camera position in world coord
in vec3 wP;  // fragment position in world coord
in vec3 wN;  // normal in world coord

out vec4 fColor;

struct Material 
{
	vec4  k_d;	// diffuse coefficient
	vec4  k_s;	// specular coefficient
	float n;	// specular exponent
};

struct Sphere 
{
	vec4     center;
	float    radius;
	Material mtl;
};

struct Ray 
{
	vec3 pos;
	vec3 dir;
};

struct HitInfo 
{
	float    t;
	vec4     position;
	vec3     normal;
	Material mtl;
};

uniform mat4 uModelMat; 
uniform mat4 uViewMat; 
uniform mat4 uProjMat; 
uniform vec4 uLPos; 
uniform vec4 uLIntensity;
uniform vec4 uAmb; 
uniform vec4 uDif; 
uniform vec4 uSpc; 
uniform float uShininess; 
uniform samplerCube uCube;
uniform vec4 uEPos;
uniform int uNumSphere;
uniform Sphere uSpheres[20];
uniform int uBounceLimit;
uniform int uDrawingMode;

const float PI = 3.14159265359;
const float EPSILON = 0.001;
const float INFINITE = 1e30;

bool IntersectRay( inout HitInfo hit, Ray ray );

// Shades the given point and returns the computed color.
vec4 Shade( Material mtl, vec4 position, vec3 normal, vec3 view )
{
	vec4 color = uAmb;
	vec3 L = normalize(uLPos.xyz - position.xyz);
	vec3 N = normalize(normal);
	vec3 V = normalize(view);
	vec3 R = reflect(-L, N);

	Ray shadowRay;
	HitInfo shadowHit;

	shadowRay.pos = position.xyz + EPSILON * N;
	shadowRay.dir = L;
	shadowHit.t = INFINITE;

	bool isShadowed = false;
	if (IntersectRay(shadowHit, shadowRay))
	{
		if (shadowHit.t > 0.0 && shadowHit.t < length(uLPos.xyz - position.xyz))
			isShadowed = true;
	}

	if (!isShadowed)
	{
		color += mtl.k_d * uLIntensity * max(dot(N, L), 0.0);	// diffuse term
		color += mtl.k_s * uLIntensity * pow(max(dot(R, V), 0.0), mtl.n); // specular term
	}
	return color;
}

// Intersects the given ray with all spheres in the scene
// and updates the given HitInfo using the information of the sphere
// that first intersects with the ray.
// Returns true if an intersection is found.
bool IntersectRay( inout HitInfo hit, Ray ray )
{
	hit.t = INFINITE;
	bool foundHit = false;
	for ( int i=0; i<uNumSphere; ++i ) 
	{
		Sphere s = uSpheres[i];

		vec3 oc = ray.pos - s.center.xyz;
		float quad_coef = dot(ray.dir, ray.dir);
		float linear_coef = 2.0 * dot(oc, ray.dir);
		float constant = dot(oc, oc) - s.radius * s.radius;
		float discriminant = linear_coef * linear_coef - 4.0 * quad_coef * constant;

		if (discriminant >= 0.0)
		{
			float root = sqrt(discriminant);
			float t = (-linear_coef - root) / (2.0 * quad_coef);
			if (t <= EPSILON)
				t = (-linear_coef + root) / (2.0 * quad_coef);
			if (t > EPSILON && t < hit.t)
			{
				hit.t = t;
				hit.position = vec4(ray.pos + t * ray.dir, 1.0);
				hit.normal = normalize(hit.position.xyz - s.center.xyz);
				hit.mtl = s.mtl;
				foundHit = true;
			}
		}
	}
	return foundHit;
}

// Given a ray, returns the shaded color where the ray intersects a sphere.
// If the ray does not hit a sphere, returns the environment color.
vec4 RayTracer( Ray ray )
{
	HitInfo hit;
	if ( IntersectRay( hit, ray ) ) 
	{
		vec3 view = normalize( -ray.dir );
		vec4 color = Shade( hit.mtl, hit.position, hit.normal, view );

		// Compute reflections
		vec4 k_s = hit.mtl.k_s;
		for ( int bounce=0; bounce < uBounceLimit; bounce++ ) 
		{
			if ( hit.mtl.k_s.r + hit.mtl.k_s.g + hit.mtl.k_s.b <= EPSILON ) break;
			
			Ray r;	// this is the reflection ray
			HitInfo h;	// reflection hit info
						
			r.dir = reflect(normalize(ray.dir), normalize(hit.normal));
			r.pos = hit.position.xyz + EPSILON * hit.normal;
			
			if ( IntersectRay( h, r ) ) 
			{
				vec3 v = normalize(-r.dir);
				vec4 reflectedColor = Shade(h.mtl, h.position, h.normal, v);
				color += k_s * reflectedColor;
				
				k_s *= h.mtl.k_s;
				ray = r;
				hit = h;
			} 
			else 
			{
				// The reflection ray did not intersect with anything, so we are using the environment color
				color += k_s * texture(uCube, vec3(1,-1,1)*r.dir);
				break;	// no more reflections
			}
		}

		return color;	// return the accumulated color, including the reflections
	} 
	else
	{
		return texture(uCube, vec3(1,-1,1)*ray.dir);	// return the environment color
	}
}

void main()
{
	if(uDrawingMode == 0) // rasterizing mode
	{
		vec3 N = normalize(N3); 
		vec3 L = normalize(L3); 
		vec3 V = normalize(V3); 
		vec3 H = normalize(V+L); 

		float NL = max(dot(N, L), 0); 
		float VR = pow(max(dot(H, N), 0), uShininess); 

		fColor = uAmb + uLIntensity*uDif*NL + uLIntensity*uSpc*VR; 
		fColor.w = 1; 

		vec3 viewDir = wP - wV;
		vec3 dir = reflect(viewDir, wN);

		fColor += uSpc*texture(uCube, vec3(1,-1,1)*dir);
	}
	else if(uDrawingMode == 1) // ray tracing mode
	{
		Ray r;
		r.pos = wV;
		r.dir = normalize(wP - wV);
		fColor = RayTracer(r);
	}
}
