#pragma once

#include <vgl.h>
#include <vec.h>

struct MySphereVertex
{
	vec4 position;
	vec4 color;
	vec3 normal;
};

class MySphere
{
public:
	MySphere(void);
	~MySphere(void);

	int NumVertices;

	MySphereVertex * Vertices;
	GLuint Init(int la_slice, int lo_slice, vec4 color=vec4(0.5,0.5,0.5,1), bool refineTop=false);
	void SetPositionAndOtherAttributes(GLuint program);

	GLuint vao;
	GLuint buffer;
	bool bInitialized;

	void Draw(GLuint program);
};



MySphere::MySphere(void)
{
	bInitialized = false;
	NumVertices = 0;
	Vertices = NULL;
}

MySphere::~MySphere(void)
{
	if(Vertices != NULL) 
		delete [] Vertices;
}

GLuint MySphere::Init(int la_slice, int lo_slice, vec4 color, bool refineTop)
{
	// The Cube should be initialized only once;
	if(bInitialized == true) return vao;

	NumVertices = (la_slice-2)*lo_slice*2*3 + 2*lo_slice*3;
	Vertices = new MySphereVertex [NumVertices];

	const float pi = 3.14159265f;
	const float db = 2.0f * pi / lo_slice;
	auto latitude = [=](int ring) {
		float t = static_cast<float>(ring) / la_slice;
		// The visible part of the ground sphere is close to its north pole.
		return (refineTop ? t * t * t : t) * pi;
	};
	int cur = 0;
	for(int i=0; i<la_slice; i++)
	{
		float theta1 = latitude(i), theta2 = latitude(i + 1);
		float y1 = cos(theta1), r1 = sin(theta1);
		float y2 = cos(theta2), r2 = sin(theta2);
		for(int j=0; j<lo_slice; j++)
		{
			vec3 a(r1*cos(db*j), y1, r1*sin(db*j));
			vec3 b(r2*cos(db*j), y2, r2*sin(db*j));
			vec3 c(r2*cos(db*(j+1)), y2, r2*sin(db*(j+1)));
			vec3 d(r1*cos(db*(j+1)), y1, r1*sin(db*(j+1)));
			
			if(i!=la_slice-1)
			{
				Vertices[cur].position = a;	Vertices[cur].color = color; Vertices[cur].normal = a; cur ++;
				Vertices[cur].position = b;	Vertices[cur].color = color; Vertices[cur].normal = b; cur ++;
				Vertices[cur].position = c;	Vertices[cur].color = color; Vertices[cur].normal = c; cur ++;
			}
			if(i!=0)
			{
				Vertices[cur].position = c;	Vertices[cur].color = color; Vertices[cur].normal = c; cur ++;
				Vertices[cur].position = d;	Vertices[cur].color = color; Vertices[cur].normal = d; cur ++;
				Vertices[cur].position = a;	Vertices[cur].color = color; Vertices[cur].normal = a; cur ++;
			}
		}
	}

	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glGenBuffers(1, &buffer);
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(MySphereVertex)*NumVertices, Vertices, GL_STATIC_DRAW);
	
	bInitialized = true;
	return vao;
}

void MySphere::SetPositionAndOtherAttributes(GLuint program)
{
	GLint vPosition = glGetAttribLocation(program, "vPosition");
	if (vPosition >= 0) {
		glEnableVertexAttribArray(vPosition);
		glVertexAttribPointer(vPosition, 4, GL_FLOAT, GL_FALSE, sizeof(MySphereVertex), BUFFER_OFFSET(0));
	}

	GLint vColor = glGetAttribLocation(program, "vColor");
	if (vColor >= 0) {
		glEnableVertexAttribArray(vColor);
		glVertexAttribPointer(vColor, 4, GL_FLOAT, GL_FALSE, sizeof(MySphereVertex), BUFFER_OFFSET(sizeof(vec4)));
	}

	GLint vNormal = glGetAttribLocation(program, "vNormal");
	if (vNormal >= 0) {
		glEnableVertexAttribArray(vNormal);
		glVertexAttribPointer(vNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MySphereVertex), BUFFER_OFFSET(sizeof(vec4)+sizeof(vec4)));
	}
	
}


void MySphere::Draw(GLuint program)
{
	if(!bInitialized) return;			// check whether it is initiazed or not. 
	
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	SetPositionAndOtherAttributes(program);
	
	glDrawArrays(GL_TRIANGLES, 0, NumVertices);
}