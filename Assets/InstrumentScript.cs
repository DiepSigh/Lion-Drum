using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InstrumentScript : MonoBehaviour
{

    public int value;
    public Text instrumentText;

    // Start is called before the first frame update
    void Start()
    {
        value = 0;
        instrumentText.text = "Drum";
    }

    public void changeInstrument(){
        value++;
        if (value==3){
            Start();
        }else if (value==2){
            instrumentText.text = "Gong";
        }else{ //if value == 1
            instrumentText.text = "Cymbals";
        }
    }
}
