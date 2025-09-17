using UnityEngine;

namespace UI
{
    public class QuitButton : MonoBehaviour
    {
        public void OnClick()
        {
            Application.Quit();
        }
    }

}
