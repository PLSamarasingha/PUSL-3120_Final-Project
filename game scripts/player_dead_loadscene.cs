using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;

public class player_dead_loadscene : MonoBehaviour
{
    private GameObject time_finish,enemy_finish;
    public player_health ph;
    private bool transitionScheduled;

    void Update()
    {
         time_finish = GameObject.FindGameObjectWithTag("time_finish");
         enemy_finish = GameObject.FindGameObjectWithTag("enemy_finish");
         if(ph.player_dead==true && time_finish==null && enemy_finish==null){ 
            SceneManager.LoadScene("game over 1");
            Cursor.visible=true;
            Cursor.lockState=CursorLockMode.None;
         }
        else if(ph.player_dead==false && time_finish==null && enemy_finish!=null){
          ScheduleWinLoad();
        }
        else if(ph.player_dead==false && time_finish!=null && enemy_finish==null){
             SceneManager.LoadScene("game over 1");
             Cursor.visible=true;
              Cursor.lockState=CursorLockMode.None;
        }
        else if(ph.player_dead==false && time_finish!=null && enemy_finish!=null){
          ScheduleWinLoad();
        }
    }

    private void ScheduleWinLoad(){
        if(transitionScheduled){
            return;
        }

        transitionScheduled=true;
        Invoke("load_scene",10);
    }

    private void load_scene(){
       SceneManager.LoadScene("won scene 1");
     Cursor.visible=true;
     Cursor.lockState=CursorLockMode.None;
    }
}
