using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace SharpLoader
{
    public partial class Form1 : Form
    {
        public const string dllName = "glrenderer.dll";

        [DllImport(dllName, EntryPoint = "renderInit")]
        public static extern int renderInit(string settings);
        [DllImport(dllName, EntryPoint = "renderDeInit")]
        public static extern int renderDeinit();
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            renderInit("settings.txt");
        }

        private void button2_Click(object sender, EventArgs e)
        {
            renderDeinit();           
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            button2_Click(this, e);
        }
    }
}
