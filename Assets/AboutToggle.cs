using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AboutToggle : MonoBehaviour
{

    public GameObject aboutImage;

    void Start(){
        aboutImage.SetActive(false);
    }

    public void ToggleOff(){
        aboutImage.SetActive(false);
    }

    public void ToggleOn(){
        aboutImage.SetActive(true);
    }
}
