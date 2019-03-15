using UnityEngine;

//ポータルエフェクト
public class PortalEffect : MonoBehaviour　{

    private readonly int _radiusID = Shader.PropertyToID("_Radius");

    private readonly int _posID = Shader.PropertyToID("_Pos");

    [SerializeField, Range(0f, 1f)]
    private float MaxRadius = 0.2f;

    private MaterialPropertyBlock block;

    private Renderer t_renderer;

    private float radius = 0f;

    private void Start() {
        t_renderer = GetComponent<Renderer>();

        block = new MaterialPropertyBlock();

        t_renderer.GetPropertyBlock(block);
    }

    private void Update() {
        if(Input.GetMouseButton(0)) {

            RaycastHit hit;

            var s_pos = Input.mousePosition;

            s_pos.z = -10f;

            var r_pos = Camera.main.ScreenToWorldPoint(s_pos);

            r_pos.x *= -1f;

            r_pos.y *= -1f;

            radius = Mathf.Clamp(radius + Time.deltaTime, 0f, MaxRadius);

            Physics.Raycast(r_pos, Vector3.forward, out hit, 100f);

            if(hit.collider != null) {
                var uv = hit.textureCoord;

                block.SetVector(_posID, uv);

                block.SetFloat(_radiusID, radius);
            }
        } else {
            radius = Mathf.Clamp(radius - Time.deltaTime, 0f, MaxRadius);

            block.SetFloat(_radiusID, radius);
        }
    }

    private void LateUpdate() {
        t_renderer.SetPropertyBlock(block);
    }

}