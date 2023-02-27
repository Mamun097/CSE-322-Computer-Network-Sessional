import matplotlib.pyplot as plt
import sys
import os

def plotMergedGraph(varying_parameter, x1, x2, y1, y2, label: str):
    title = label + ' vs ' + varying_parameter
    xlabel = varying_parameter
    ylabel = label
    fig, ax = plt.subplots()
    ax.plot(x1, y1, label=label, color="red", linestyle="--")
    ax.plot(x2, y2, label=label+" modified",color="blue")
    ax.scatter(x1, y1, color="red")
    ax.scatter(x2, y2, color="blue")
    ax.legend()
    ax.grid(True)

    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    
    folder = title.split(' vs ')[1]
    filename = title+'.png'
    fig.savefig('graphs/'+folder+"/"+filename)
    plt.close(fig)

def parseAndGraph(unmodified_output_file, modified_output_file, varying_parameter : str):
    param = []
    throughput = []
    avgDelay = []
    deliveryRatio = []
    dropRatio = []
    energy = []

    param_modified = []
    throughput_modified = []
    avgDelay_modified = []
    deliveryRatio_modified = []
    dropRatio_modified = []
    energy_modified = []

    with open(unmodified_output_file, 'r') as inputFile:
        for line in inputFile:
            if line.startswith(varying_parameter):
                param.append(int(line.split(sep=" ")[1]))
            else:
                tokens = line.split(sep=" ")
                throughput.append(float(tokens[0]))
                avgDelay.append(float(tokens[1]))
                deliveryRatio.append(float(tokens[2]))
                dropRatio.append(float(tokens[3]))
                energy.append(float(tokens[4]))

    with open(modified_output_file, 'r') as inputFile:
        for line in inputFile:
            if line.startswith(varying_parameter):
                param_modified.append(int(line.split(sep=" ")[1]))
            else:
                tokens = line.split(sep=" ")
                throughput_modified.append(float(tokens[0]))
                avgDelay_modified.append(float(tokens[1]))
                deliveryRatio_modified.append(float(tokens[2]))
                dropRatio_modified.append(float(tokens[3]))
                energy_modified.append(float(tokens[4]))
    
    plotMergedGraph(varying_parameter, param, param_modified, throughput, throughput_modified, "Throughput")
    plotMergedGraph(varying_parameter, param, param_modified, avgDelay, avgDelay_modified, "Average Delay")
    plotMergedGraph(varying_parameter, param, param_modified, deliveryRatio, deliveryRatio_modified, "Delivery Ratio")
    plotMergedGraph(varying_parameter, param, param_modified, dropRatio, dropRatio_modified, "Drop Ratio")
    plotMergedGraph(varying_parameter, param, param_modified, energy, energy_modified, "Energy Consumption")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 graphGenerator.py <input_file1> <input_file2> <varying_parameter>")
        exit(1)
    
    if not os.path.isdir('graphs'): os.mkdir('graphs')
    if not os.path.isdir('graphs/node'): os.mkdir('graphs/node')
    if not os.path.isdir('graphs/flow'): os.mkdir('graphs/flow')
    if not os.path.isdir('graphs/packet'):os.mkdir('graphs/packet')
    if not os.path.isdir('graphs/speed'):os.mkdir('graphs/speed')
    
    parseAndGraph(sys.argv[1], sys.argv[2], sys.argv[3])
