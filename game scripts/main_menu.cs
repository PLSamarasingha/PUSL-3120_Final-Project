using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class main_menu : MonoBehaviour
{
    public AudioSource ads;

    void Start()
    {
        ads.Play();
    }

    public void playGame()
    {
        SceneManager.LoadScene("level_loader");
    }

    public void openModeSelect()
    {
        SceneManager.LoadScene("game");
    }

    public void quit()
    {
        Application.Quit();
    }
}
