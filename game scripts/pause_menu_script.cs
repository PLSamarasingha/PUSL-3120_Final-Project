using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
#if UNITY_EDITOR
using UnityEditor;
#endif
public class pause_menu_script : MonoBehaviour
{
   private const string MainMenuSceneName = "game";
   public bool gamepaused=false;
//    public front_canvas_score_kill_script spk;
   public AudioSource ads1,ads2;
   public GameObject pausemenu_ui;

void Start(){
    if(ads1 != null){
        ads1.Play();
    }
}
    // Update is called once per frame
    void Update()
    {

        if(gamepaused){
             if(ads1 != null && ads1.isPlaying){
                 ads1.Stop();
             }
              if(ads2 != null && ads2.isPlaying){
                 ads2.Stop();
             }
             else if(ads2 != null){
             ads2.Play();
             }
            }
        else{
            if(ads2 != null && ads2.isPlaying){
                ads2.Stop();
            }
            if(ads1 != null && ads1.isPlaying){
                ads1.Stop();
            }
            else if(ads1 != null){
            ads1.Play();
            }
            }



       if(gamepaused){
           if(Input.GetKeyDown(KeyCode.Tab)){
                mainMenu();
        }
       }
        if(gamepaused){
           if(Input.GetKeyDown(KeyCode.Q)){
                quitGame();
        }
       }
        if(Input.GetKeyDown(KeyCode.Escape)){
            if(gamepaused){
                resume();
            }
            else{
                pause();
            }
        }
        
    }
    public void resume(){
        pausemenu_ui.SetActive(false);
        Time.timeScale=1f;
        gamepaused=false;
    }
    public void pause(){
        pausemenu_ui.SetActive(true);
        Time.timeScale=0f;
        gamepaused=true;
    }

    public void mainMenu(){
        Time.timeScale = 1f;
        gamepaused = false;
        SceneManager.LoadScene(MainMenuSceneName);
    }

    public void MainMenu(){
        mainMenu();
    }

    public void quitGame(){
        Time.timeScale = 1f;
        gamepaused = false;
#if UNITY_EDITOR
        EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }

    public void QuitGame(){
        quitGame();
    }
}
