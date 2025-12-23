# Ray-Tracing

This project implements a Ray-Tracing algorithm within the Fragment Shader stage of the standard graphics pipeline.

<video src="https://github.com/user-attachments/assets/ea9d9bd6-7314-4e81-b158-2cb0a61582e3" width="400" controls><\video>

## Implementation Features

* **Fragment Shader-based**: All ray-tracing calculations are performed within the GPU's fragment shader.
* **Sphere Primitives**: Uses only spheres for computational efficiency, determining intersections via analytic solutions.
* **Cube Mapping**: Implements environmental lighting and reflections using cube map textures.

## Ray-Sphere Intersection

The intersection between a ray and a sphere is calculated using the following equations:



* **Ray**: $P(t) = O + tD$
* **Sphere**: $\|P - C\|^2 = r^2$
* **Intersection Formula**: The intersection point is determined by solving the quadratic equation for $t$: $$t^2(D \cdot D) + 2t(D \cdot (O - C)) + (O - C) \cdot (O - C) - r^2 = 0$$

## Manual

- '1': Increase Number of Sphere
- '2': Decrease Number of Sphere
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/9e60f38b-47f1-45de-a78f-3df738b0ed73" />
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/0cf0e165-dc4f-4cdb-9202-227d61fc6305" />


<br>
<br>

- '3': Increase Bounce Limit
- '4': Decrease Bounce Limit
<table style="margin-left: auto; margin-right: auto;">
  <tr>
    <td align="center" valign="bottom">
      <img src="https://github.com/user-attachments/assets/41393616-50f6-4067-aa61-e90d7dba0ce3" width="100%" />
      <br />
      <sub>Bounce Limit = 2</sub>
    </td>
    <td align="center" valign="bottom">
      <img src="https://github.com/user-attachments/assets/4a60597f-10c0-4b0b-8fd7-328708468d95" width="100%" />
      <br />
      <sub>Bounce Limit = 1</sub>
    </td>
    <td align="center" valign="bottom">
      <img src="https://github.com/user-attachments/assets/191b473f-096d-4bd2-9d7c-f6addf80f507" width="100%" />
      <br />
      <sub>Bounce Limit = 0</sub>
    </td>
  </tr>
</table>

<br>

- '5': Increase Camera Height
- '6': Decrease Camera Height
<img width="30.5%" alt="image" src="https://github.com/user-attachments/assets/2ab1edbd-495e-4cb2-a0af-8c1199543798" />
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/ee0ebbc0-cec2-425c-b986-b3061dc8b2e1" />

<br>
<br>

- 'Enter': Toggle Shading Mode

    - 0: Rasterizing Mode(Only Phong Shading)
    - 1: RayTracing Mode
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/f06c0c68-780c-4dfd-ad10-cd1abe93d77b" />
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/c8327953-e20f-4493-82a9-3f67711a129e" />

<br>
<br>

- 'R': Reset
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/fed4e46a-1e32-446d-90f9-7e87b345f1a5" />
<img width="30%" alt="image" src="https://github.com/user-attachments/assets/0493903d-ba17-4b79-8a55-5a68bbdb0ef1" />

