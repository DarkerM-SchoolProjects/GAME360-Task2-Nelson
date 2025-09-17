using UnityEngine;
using UnityEngine.SceneManagement;

namespace UI
{
    public class StartButton : MonoBehaviour
    {

        private AsyncOperation asyncLoad;
        private Scene currentScene;

        private void Start()
        {
            // Start loading the 1 scene in the background
            asyncLoad = SceneManager.LoadSceneAsync(1, LoadSceneMode.Additive);
            asyncLoad.allowSceneActivation = false;

            // Get the current active scene
            currentScene = SceneManager.GetActiveScene();
        }

        public void OnClick()
        {
            if (asyncLoad != null && asyncLoad.progress >= 0.9f)
            {
                // Allow scene activation
                asyncLoad.allowSceneActivation = true;

                // After activation, unload current active scene
                StartCoroutine(UnloadCurrentScene());
            }
        }

        private System.Collections.IEnumerator UnloadCurrentScene()
        {
            // Wait until the new scene is fully loaded
            while (!asyncLoad.isDone)
            {
                yield return null;
            }
            // Unload the current active scene
            AsyncOperation unloadOperation = SceneManager.UnloadSceneAsync(currentScene);
            // Wait until the current scene is unloaded
            while (!unloadOperation.isDone)
            {
                yield return null;
            }
            // Set the newly loaded scene as the active scene
            Scene newScene = SceneManager.GetSceneByBuildIndex(1);
            SceneManager.SetActiveScene(newScene);
        }
    }

}
